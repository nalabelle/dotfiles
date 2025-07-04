{ config, lib, pkgs, ... }:

let
  # Read base MCP settings
  baseSettings = lib.importJSON ../config/vscode/kilocode-mcp-settings.json;

  # Merge base settings with host-specific MCP servers
  mergedSettings = lib.recursiveUpdate baseSettings {
    mcpServers = config.vscode.hostMcpServers;
  };

  # Create the settings file content with pretty JSON formatting
  settingsFile = pkgs.runCommand "mcp_settings.json" { } ''
    echo '${
      lib.generators.toJSON { } mergedSettings
    }' | ${pkgs.jq}/bin/jq '.' > $out
  '';

  # Extract VS Code config directory name based on package
  vscodePname = if pkgs.stdenv.isDarwin then
    # On macOS, we use a wrapper, so we need to determine the actual VS Code type
    "vscode"
  else
    # On Linux, use the actual package name
    pkgs.vscode.pname;

  configDir = {
    "vscode" = "Code";
    "vscode-insiders" = "Code - Insiders";
    "vscodium" = "VSCodium";
    "openvscode-server" = "OpenVSCode Server";
    "windsurf" = "Windsurf";
    "cursor" = "Cursor";
  }.${vscodePname};

  # Build platform-specific state database path
  configPath = if pkgs.stdenv.isDarwin then
    "Library/Application Support/${configDir}"
  else
    "${config.xdg.configHome}/${configDir}";


  # Create a source directory with all kilocode files (rules and workflows)
  kilocodeSource = pkgs.runCommand "kilocode-source" { } ''
    mkdir -p $out
    cp -r ${../config/kilocode}/* $out/
  '';

  # Create script to update VS Code state database with Kilocode settings
  updateStateScript = pkgs.writeShellScript "update-vscode-state" ''
    set -euo pipefail

    STATE_DB="$1"
    SETTINGS_JSON="$2"

    if [ ! -f "$STATE_DB" ]; then
      echo "No state database found: $STATE_DB"
      exit 0
    fi

    # Create database backup with timestamp-based naming
    create_backup() {
      local db_path="$1"
      local db_dir=$(dirname "$db_path")
      local db_name=$(basename "$db_path")
      local timestamp=$(${pkgs.coreutils}/bin/date +"%Y%m%d-%H%M%S")
      local backup_path="$db_dir/$db_name.backup.$timestamp"

      echo "Creating backup: $backup_path"
      if ${pkgs.coreutils}/bin/cp "$db_path" "$backup_path" 2>/dev/null; then
        echo "Backup created successfully"
      else
        echo "Warning: Failed to create backup, continuing with update"
        return 1
      fi

      # Clean up old backups, keeping only 5 generations
      local backup_pattern="$db_dir/$db_name.backup.*"
      local old_backups=$(${pkgs.findutils}/bin/find "$db_dir" -name "$db_name.backup.*" -type f | ${pkgs.coreutils}/bin/sort -r | ${pkgs.coreutils}/bin/tail -n +6)

      if [ -n "$old_backups" ]; then
        echo "Removing old backups:"
        echo "$old_backups" | while read -r old_backup; do
          echo "  Removing: $old_backup"
          ${pkgs.coreutils}/bin/rm -f "$old_backup" 2>/dev/null || echo "  Warning: Failed to remove $old_backup"
        done
      fi
    }

    # Create backup before any write operations
    create_backup "$STATE_DB" || echo "Backup failed, but continuing with database update"

    # Get existing value for kilocode.kilo-code key
    EXISTING_VALUE=$(${pkgs.sqlite}/bin/sqlite3 "$STATE_DB" "SELECT value FROM ItemTable WHERE key = 'kilocode.kilo-code';" 2>/dev/null || echo "{}")

    # If no existing value, use empty object
    if [ -z "$EXISTING_VALUE" ] || [ "$EXISTING_VALUE" = "" ]; then
      EXISTING_VALUE="{}"
    fi

    # Read new settings from JSON file
    NEW_SETTINGS=$(cat "$SETTINGS_JSON")

    # Merge existing settings with new settings using jq
    # The new settings will override existing ones with the same keys
    MERGED_VALUE=$(echo "$EXISTING_VALUE" | ${pkgs.jq}/bin/jq --argjson new "$NEW_SETTINGS" '. * $new')

    # Update or insert the merged value
    ${pkgs.sqlite}/bin/sqlite3 "$STATE_DB" "INSERT OR REPLACE INTO ItemTable (key, value) VALUES ('kilocode.kilo-code', '$MERGED_VALUE');"

    echo "Updated VS Code state database with Kilocode settings"
  '';

in {
  options.vscode.hostMcpServers = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Host-specific MCP servers for VSCode";
  };

  config = {
    # Use Home Manager's vscode module but with Homebrew-installed VS Code
    # We create a lightweight wrapper package that points to the Homebrew installation
    programs.vscode = {
      # Source: https://github.com/nix-community/home-manager/blob/master/modules/programs/vscode/default.nix
      enable = true;

      # Platform-specific package handling:
      # - macOS: Use wrapper for Homebrew-installed VS Code (avoids extra Nix installation)
      # - Linux: Use regular Nix package
      package = if pkgs.stdenv.isDarwin then
        pkgs.runCommand "vscode-homebrew-wrapper" {
          pname = "vscode";
          version = "homebrew";
          meta.mainProgram = "code";
        } ''
          mkdir -p $out/bin

          # Create symlink to Homebrew-installed VS Code
          ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" $out/bin/code
        ''
      else
        # Use regular Nix package on Linux
        pkgs.vscode;

      # Configure extensions using Home Manager's built-in functionality
      profiles.default = {
        # UpdateChecks apply to all profiles
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        userSettings = lib.importJSON ../config/vscode/settings.json;
        extensions = with pkgs.nix-vscode-extensions.vscode-marketplace; [
          alefragnani.project-manager
          editorconfig.editorconfig
          jetpack-io.devbox
          kilocode.kilo-code
          michelemelluso.gitignore
          mikestead.dotenv
          mkhl.direnv
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vscode.makefile-tools
          ms-vscode.remote-explorer
          vscodevim.vim
          jnoortheen.nix-ide
        ];
      };
    };

    # MCP settings for Kilo Code extension
    # This only manages the settings file, not the VSCode installation

    # macOS MCP settings
    home.file."${configPath}/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" =
      lib.mkIf pkgs.stdenv.isDarwin { source = settingsFile; };

    # Kilo Code rule files (both platforms)
    #
    # WORKAROUND: Using activation scripts to copy files instead of symlinks.
    # This works around a Kilocode extension bug where the rule loading logic
    # excludes symlinks.
    #
    # Bug locations in https://github.com/Kilo-Org/kilocode:
    # - src/core/webview/kilorules.ts:60 (primary rule filtering logic)
    # - src/utils/fs.ts:84 (utility function with same issue)
    #
    # The issue is that `file.isFile()` excludes symlinks - the fix would be to add
    # `|| file.isSymbolicLink()` to these checks.
    #
    # This workaround can be reverted to `source` once the extension is fixed.

    home.activation.kilocodeFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create .kilocode directory structure
      mkdir -p "$HOME/.kilocode"

      # Check if .kilocode directory has symlinks that need to be replaced
      # This is necessary because rsync doesn't always overwrite symlinks correctly
      # and the Kilocode extension specifically excludes symlinks
      if find "$HOME/.kilocode" -type l -print -quit | grep -q .; then
        echo "Replacing symlinks in .kilocode directory"
        find "$HOME/.kilocode" -type l -delete
      fi

      # Sync entire kilocode directory structure (rules and workflows)
      # --update: only copy if source is newer or content differs
      # --delete: remove files in destination that don't exist in source
      # --recursive: sync directory contents recursively
      ${pkgs.rsync}/bin/rsync --delete --recursive \
        "${kilocodeSource}/" \
        "$HOME/.kilocode/"
    '';

    # Update VS Code state database with Kilocode extension settings
    home.activation.kilocodeState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Build full state database path using configPath
      STATE_VSCDB="$HOME/${configPath}/User/globalStorage/state.vscdb"

      # Call the update script with database path and settings file
      ${updateStateScript} "$STATE_VSCDB" "${../config/vscode/kilocode-state.json}"
    '';

    # Linux MCP settings
    xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
      "Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" =
        {
          source = settingsFile;
        };
    };
    # Linux systemd user services for Qdrant and Ollama (VS Code context)
    systemd.user.services = lib.mkIf pkgs.stdenv.isLinux {
      qdrant = lib.mkIf (pkgs ? qdrant && pkgs ? vscode) {
        Unit = {
          Description = "Qdrant Vector Database (User Service)";
          After = [ "network.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.qdrant}/bin/qdrant --disable-telemetry";
          WorkingDirectory = "/tmp";
          Restart = "always";
          LimitNOFILE = 10240;
          Environment = [
            "QDRANT__STORAGE__STORAGE_PATH=%h/.local/share/qdrant/storage"
            "QDRANT__STORAGE__SNAPSHOTS_PATH=%h/.local/share/qdrant/snapshots"
            "QDRANT__STORAGE__TEMP_PATH=%h/.local/share/qdrant/temp"
          ];
          ExecStartPre = ''
            ${pkgs.coreutils}/bin/mkdir -p %h/.local/share/qdrant/storage %h/.local/share/qdrant/snapshots %h/.local/share/qdrant/temp
          '';
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
      ollama = lib.mkIf (pkgs ? ollama && pkgs ? vscode) {
        Unit = { Description = "Ollama LLM Service"; };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.ollama}/bin/ollama start";
          ExecStartPost = "${pkgs.ollama}/bin/ollama pull nomic-embed-text";
          Restart = "always";
          LimitNOFILE = 10240;
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
    };
  };
}
