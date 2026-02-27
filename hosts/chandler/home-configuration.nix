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

  home.packages = [
    inputs.opencode.packages.x86_64-linux.default
    inputs.kilocode.packages.x86_64-linux.default
    pkgs.btop
  ];

  systemd.user.services.opencode = {
    Unit = {
      Description = "OpenCode web server";
      X-Restart-Triggers = [ config.home.file.".config/opencode/opencode.json".source ];
    };
    Service = {
      ExecStart = "${inputs.opencode.packages.x86_64-linux.default}/bin/opencode web --port 4096 --hostname 127.0.0.1";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "5s";
      Environment = "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:%h/.nix-profile/bin";
      EnvironmentFile = "-${config.home.homeDirectory}/.config/credentials/opencode.env";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.kilocode = {
    Unit = {
      Description = "KiloCode web server";
      X-Restart-Triggers = [ config.home.file.".config/kilo/opencode.json".source ];
    };
    Service = {
      ExecStart = "${inputs.kilocode.packages.x86_64-linux.default}/bin/kilo web --port 4097 --hostname 127.0.0.1";
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

  systemd.user.timers.kilocode-restart = {
    Unit.Description = "Daily restart timer for KiloCode web server";
    Timer = {
      OnCalendar = "*-*-* 05:00:00 America/New_York";
      RandomizedDelaySec = "10m";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.kilocode-restart = {
    Unit = {
      Description = "Restart KiloCode web server";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart kilocode.service";
    };
  };
}
