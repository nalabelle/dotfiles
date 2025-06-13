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

in {
  options.vscode.hostMcpServers = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Host-specific MCP servers for VSCode";
  };

  config = {
    # MCP settings for Kilo Code extension
    # This only manages the settings file, not the VSCode installation

    # macOS path
    home.file = lib.mkIf pkgs.stdenv.isDarwin {
      "Library/Application Support/Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" =
        {
          source = settingsFile;
        };
    };

    # Linux path
    xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
      "Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" =
        {
          source = settingsFile;
        };
    };
  };
}
