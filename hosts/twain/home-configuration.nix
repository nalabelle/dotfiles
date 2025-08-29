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

  # Enable SSH for GitHub authentication
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
    '';
  };

  # Configure home-manager auto-upgrade for flakes
  systemd.user.services.home-manager-auto-upgrade = {
    Service = {
      Environment = "PATH=/run/current-system/sw/bin";
      ExecStart = lib.mkForce "${pkgs.home-manager}/bin/home-manager switch --flake .#${config.home.username}@twain";
    };
  };
}
