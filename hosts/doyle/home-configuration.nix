{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  # Enable integration with generic Linux desktop environments
  targets.genericLinux.enable = true;

  # Configure VS Code to use VS Code SSH path
  vscode.configPath = ".vscode-server/data";

  home.packages = with pkgs; [
    _1password-gui
    brave
    vscode-fhs
    opencode
    btop
  ];

}
