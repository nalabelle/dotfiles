{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
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
