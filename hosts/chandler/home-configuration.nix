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
    };
    Install.WantedBy = [ "default.target" ];
  };
}
