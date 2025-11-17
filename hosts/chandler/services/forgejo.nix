# Forgejo Git service and Actions runners configuration

{
  config,
  pkgs,
  lib,
  services_domain,
  ...
}:

let
  # Define runner instances
  runnerInstances = {
    marlowe = "Marlowe";
    spade = "Spade";
  };

  # Common configuration for all Forgejo runners
  runnerConfig = name: {
    enable = true;
    inherit name;
    url = "https://git.${services_domain}/";
    # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
    tokenFile = config.services.onepassword-secrets.secretPaths.forgejoRunnerToken;
    labels = [
      "ubuntu-latest:docker://node:24-bullseye"
      "ubuntu-22.04:docker://node:24-bullseye"
      "nixos-latest:docker://nixos/nix"
      "native:host"
    ];
    hostPackages = with pkgs; [
      bash
      coreutils
      curl
      gitMinimal
      gnumake
      nix
      nixos-rebuild
      nodejs_latest
      openssh
      wget
    ];
  };

  # Generate list of service names for the restart script
  serviceNames = lib.mapAttrsToList (name: _: "gitea-runner-${name}.service") runnerInstances;
  servicesListContent = lib.concatMapStringsSep "\n  " (s: ''"${s}"'') serviceNames;

  # Create restart script with injected service names
  restartScript = pkgs.replaceVars ./gitea-runner-restart.sh {
    servicesList = servicesListContent;
  };
in
{
  # Configure 1Password secrets for Forgejo
  services.onepassword-secrets.secrets = {
    forgejoRunnerToken = {
      reference = "op://Applications/Forgejo/runner-token";
      services = [ "forgejo" ] ++ (lib.mapAttrsToList (name: _: "gitea-runner-${name}") runnerInstances);
      mode = "0640";
      owner = "root";
      group = "forgejo";
    };
  };

  # Enable Forgejo service
  services.forgejo = {
    enable = true;
    database = {
      type = "postgres";
    };
    lfs.enable = true;

    settings = {
      server = {
        PROTOCOL = "http+unix";
        ROOT_URL = "https://git.${services_domain}/";
        DOMAIN = "git.${services_domain}";
      };
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
    };
    dump.enable = true;
  };

  # Configure Forgejo Actions runners
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances = lib.mapAttrs (name: displayName: runnerConfig displayName) runnerInstances;
  };

  # Smart restart timer to prevent gitea-runner memory leaks
  # Restarts every 3 days but only when no jobs are running
  systemd.timers.gitea-runner-restart = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00 America/Los_Angeles"; # Run at 2 AM PST/PDT daily
      Persistent = true;
      RandomizedDelaySec = "1h"; # Random delay up to 1 hour
    };
  };

  systemd.services.gitea-runner-restart = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${pkgs.bash}/bin/bash ${restartScript}";
      PATH = "${pkgs.systemd}/bin:${pkgs.procps}/bin:${pkgs.coreutils}/bin";
    };
  };
}
