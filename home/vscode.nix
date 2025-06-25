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

  # Create a source directory with all kilocode rule files
  kilocodeRulesSource = pkgs.runCommand "kilocode-rules-source" { } ''
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
    # MCP settings for Kilo Code extension
    # This only manages the settings file, not the VSCode installation

    # macOS MCP settings
    home.file."Library/Application Support/Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" =
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

    home.activation.kilocodeRules = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create .kilocode/rules directory
      mkdir -p "$HOME/.kilocode/rules"

      # Check if target directory has symlinks that need to be replaced
      if find "$HOME/.kilocode/rules" -type l -print -quit | grep -q .; then
        echo "Replacing symlinks in .kilocode/rules directory"
        find "$HOME/.kilocode/rules" -type l -delete
      fi

      # Sync entire directory with deletion of orphaned files
      # --update: only copy if source is newer or content differs
      # --delete: remove files in destination that don't exist in source
      # --recursive: sync directory contents recursively
      ${pkgs.rsync}/bin/rsync --update --delete --recursive \
        "${kilocodeRulesSource}/" \
        "$HOME/.kilocode/rules/"
    '';

    # Linux MCP settings
    xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
      "Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" =
        {
          source = settingsFile;
        };
    };
  };
}
