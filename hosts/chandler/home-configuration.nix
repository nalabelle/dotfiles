{
  config,
  pkgs,
  lib,
  ...
}:

let
  opencode-cli = pkgs.callPackage ../../nix/pkgs/opencode-cli.nix { };
  kilocode-cli = pkgs.callPackage ../../nix/pkgs/kilocode-cli.nix { };
in

{
  # Configure VS Code to use VS Code SSH path
  vscode.configPath = ".vscode-server/data";

  home.packages = [
    opencode-cli
    kilocode-cli
    pkgs.btop
  ];

  systemd.user.services.opencode = {
    Unit = {
      Description = "OpenCode web server";
      X-Restart-Triggers = [ config.home.file.".config/opencode/opencode.json".source ];
    };
    Service = {
      ExecStart = "${opencode-cli}/bin/opencode web --port 4096 --hostname 127.0.0.1";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "5s";
      Environment = "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:%h/.nix-profile/bin";
      EnvironmentFile = "-${config.home.homeDirectory}/.config/credentials/opencode.env";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.timers.opencode-restart = {
    Unit.Description = "Daily restart timer for OpenCode web server";
    Timer = {
      OnCalendar = "*-*-* 05:00:00 America/New_York";
      RandomizedDelaySec = "10m";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.opencode-restart = {
    Unit = {
      Description = "Restart OpenCode web server";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart opencode.service";
    };
  };
}
