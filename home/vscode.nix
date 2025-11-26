{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let

  # Read base MCP settings and merge with host-specific servers
  baseSettings = lib.importJSON ../config/vscode/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json;

  # Merge base settings with host-specific MCP servers
  mergedSettings = lib.recursiveUpdate baseSettings {
    mcpServers = config.vscode.hostMcpServers;
  };

  # Extract VS Code config directory name based on package
  vscodePname =
    if pkgs.stdenv.isDarwin then
      # On macOS, we use a wrapper, so we need to determine the actual VS Code type
      "vscode"
    else
      # On Linux, use the actual package name
      pkgs.vscode.pname;

  configDir =
    {
      "vscode" = "Code";
      "vscode-insiders" = "Code - Insiders";
      "vscodium" = "VSCodium";
      "openvscode-server" = "OpenVSCode Server";
      "windsurf" = "Windsurf";
      "cursor" = "Cursor";
    }
    .${vscodePname};

  # Build platform-specific state database path (can be overridden by host config)
  configPath = config.vscode.configPath;

  # Create a source directory with all kilocode files (rules and workflows)
  kilocodeSource = pkgs.runCommand "kilocode-source" { } ''
    mkdir -p $out
    cp -r ${../config/kilocode}/* $out/
  '';

in
{
  options.vscode.hostMcpServers = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Host-specific MCP servers for VSCode";
  };

  options.vscode.configPath = lib.mkOption {
    type = lib.types.str;
    default =
      if pkgs.stdenv.isDarwin then
        "Library/Application Support/${configDir}"
      else
        "${config.xdg.configHome}/${configDir}";
    description = "Override the VS Code configuration path (useful for VS Code Server)";
  };

  config = {
    # MCP settings for Kilo Code extension
    home.file."${configPath}/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" = {
      text = builtins.toJSON mergedSettings;
    };

    # VS Code keybindings - managed declaratively
    home.file."${configPath}/User/keybindings.json" = lib.mkIf pkgs.stdenv.isDarwin {
      source = ../config/vscode/User/keybindings.darwin.jsonc;
    };

    # OpenCode configuration file
    home.file.".config/opencode/opencode.json" = {
      source = ../config/opencode/opencode.json;
    };

    # Kilocode custom modes file
    home.file."${configPath}/User/globalStorage/kilocode.kilo-code/settings/custom_modes.yaml" = {
      source = ../config/vscode/User/globalStorage/kilocode.kilo-code/settings/custom_modes.yaml;
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
  };
}
