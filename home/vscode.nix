{ config, lib, pkgs, ... }:

let
  # Import merge-vscode-settings package
  mergeVscodeSettings =
    import ../node/merge-vscode-settings.nix { inherit pkgs; };

  # Create the settings file content with 1Password secret resolution
  settingsFile = pkgs.runCommand "mcp_settings.json" {
    buildInputs = [ pkgs._1password-cli ];
  } ''
    # Use op inject to resolve 1Password references in the template
    ${pkgs._1password-cli}/bin/op inject \
      --in-file ${
        ../config/vscode/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json
      } \
      --out-file base_settings.json || {
      echo "Warning: Could not resolve 1Password secrets. Using template as-is."
      cp ${
        ../config/vscode/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json
      } base_settings.json
    }

    # Merge with host-specific MCP servers
    ${pkgs.jq}/bin/jq --argjson hostServers '${
      lib.generators.toJSON { } config.vscode.hostMcpServers
    }' \
      '.mcpServers = (.mcpServers + $hostServers)' \
      base_settings.json > $out
  '';

  # VS Code user settings
  userSettings = {
    # Privacy and telemetry settings
    "telemetry.feedback.enabled" = false;
    "telemetry.telemetryLevel" = "off";

    # Project Manager extension settings
    "remote.extensionKind" = {
      "alefragnani.project-manager" = [ "workspace" ];
    };
    "projectManager.sortList" = "Path";
    "projectManager.showParentFolderInfoOnDuplicates" = true;
    "projectManager.removeCurrentProjectFromList" = false;
    "projectManager.git.maxDepthRecursion" = 1;
    "projectManager.git.baseFolders" = [
      "/Users/nalabelle/git" # macOS path
      "/home/nalabelle/git" # Linux path
    ];
    "projectManager.git.ignoredFolders" = [
      "node_modules"
      "out"
      "typings"
      "test"
      ".haxelib"
      ".devbox"
      ".venv"
      "result" # Nix build result directory
    ];
    "projectManager.vscode.baseFolders" = [
      "/Users/nalabelle/git" # macOS path
      "/home/nalabelle/git" # Linux path
    ];
    "projectManager.vscode.ignoredFolders" = [
      "node_modules"
      "out"
      "typings"
      "test"
      ".devbox"
      ".venv"
      "result" # Nix build result directory
    ];

    # Git repository scanning settings
    "git.repositoryScanIgnoredFolders" = [ "node_modules" ".devbox" ".venv" ];

    # Makefile extension settings
    "makefile.configureOnOpen" = false;

    # Auto-run command settings for Kilo Code
    "auto-run-command.rules" = [{
      condition = "always";
      command =
        "kilo-code.importSettings ${config.home.homeDirectory}/.kilocode/settings.json";
      message = "Importing Kilo Code settings from file";
    }];
  };

  # Create VS Code user settings file (base settings from Nix)
  userSettingsFile = pkgs.runCommand "settings.json" { } ''
    echo '${
      lib.generators.toJSON { } userSettings
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

in {
  options.vscode.hostMcpServers = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Host-specific MCP servers for VSCode";
  };

  config = {
    # VS Code user settings - merged with existing settings via activation script
    home.activation.vscodeSettings =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        EXISTING_SETTINGS="$HOME/${configPath}/User/settings.json"
        MANAGED_SETTINGS="${userSettingsFile}"

        if [ -f "$EXISTING_SETTINGS" ]; then
          # Merge existing settings with managed settings (managed settings take precedence)
          echo "Merging existing VS Code settings with managed settings..."

          # Use comment-preserving merge tool for JSONC format
          if ${mergeVscodeSettings}/bin/merge-vscode-settings "$EXISTING_SETTINGS" "$MANAGED_SETTINGS" "$EXISTING_SETTINGS.tmp"; then
            mv "$EXISTING_SETTINGS.tmp" "$EXISTING_SETTINGS"
          else
            echo "Warning: Skipping VS Code settings merge due to error"
          fi
        fi
        # If no existing settings file exists, silently exit without creating one
      '';

    # MCP settings for Kilo Code extension
    # This only manages the settings file, not the VSCode installation
    home.file."${configPath}/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" =
      {
        source = settingsFile;
      };

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
