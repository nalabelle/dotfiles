{ config, lib, pkgs, ... }:

{
  # MCP settings for Kilo Code extension
  # This only manages the settings file, not the VSCode installation
  
  # macOS path
  home.file = lib.mkIf pkgs.stdenv.isDarwin {
    "Library/Application Support/Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" = {
      source = ../config/vscode/kilocode-mcp-settings.json;
    };
  };
  
  # Linux path
  xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
    "Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" = {
      source = ../config/vscode/kilocode-mcp-settings.json;
    };
  };
}