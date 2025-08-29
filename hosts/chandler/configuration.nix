# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# sudo nixos-rebuild switch --flake ~/git/dotfiles#chandler

{
  config,
  lib,
  pkgs,
  ...
}:
let
  services_domain = "oops.city";
in
{
  imports = [
    # Include the results of the hardware scan. (Not tracked in git)
    # sudo nixos-generate-config --dir ~/git/dotfiles/hosts/chandler
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  # needed for initial setup. Once os os running
  # zfs change-key -o keylocation=file:///boot/zfs.key yourpool
  # then enable the secrets below
  #boot.zfs.requestEncryptionCredentials = true;

  boot.initrd.secrets = {
    "/boot/zfs.key" = null; # will copy this file into the initrd
  };

  networking.hostName = "chandler"; # Define your hostname.
  networking.hostId = "eb034881";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    #   font = "Lat2-Terminus16";
    keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.nalabelle = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ]; # Enable 'sudo' for the user and add to docker group.
    packages = with pkgs; [ ];
  };

  programs.nix-ld.enable = true;

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    git
    docker

    # for syncoid
    mbuffer
    lzop
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable Docker service
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      fixed-cidr-v6 = "fd00::/80";
      ipv6 = true;
    };
  };

  # CPU frequency scaling for power management
  # Automatically scales CPU frequency down when idle
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    powertop.enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # Configure root user SSH authorized keys
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfU1p/YuQOkLEJTH3HuxX8tAMu2P8gxh2zo2UN1tUjL root@shelley"
  ];

  # Configure 1Password secrets for system services
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = [
      "nalabelle"
      "acme"
    ];
    secrets = {
      cloudflareDnsApiToken = {
        reference = "op://Applications/PROXY/CF_DNS_API_TOKEN";
        services = [
          "acme"
        ];
        mode = "0640";
        owner = "root";
        group = "acme";
      };
      cloudflareZoneApiToken = {
        reference = "op://Applications/PROXY/CF_ZONE_API_TOKEN";
        services = [
          "acme"
        ];
        mode = "0640";
        owner = "root";
        group = "acme";
      };
      forgejoRunnerToken = {
        reference = "op://Applications/Forgejo/runner-token";
        services = [
          "forgejo"
          "gitea-runner-default"
        ];
        mode = "0640";
        owner = "root";
        group = "forgejo";
      };
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

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.default = {
      enable = true;
      name = "Default";
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
        nix
        coreutils
        gitMinimal
        curl
        wget
        nodejs_latest
      ];
    };
  };

  # Enable nginx web server with reverse proxy for Forgejo
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."git.${services_domain}" = {
      forceSSL = true;
      enableACME = false;
      useACMEHost = services_domain;
      locations."/" = {
        proxyPass = "http://unix:/run/forgejo/forgejo.sock";
        proxyWebsockets = true;
      };
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  # Let's Encrypt certificate management
  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@${services_domain}";
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    defaults.extraLegoFlags = [
      "--dns.propagation-disable-ans"
      "--dns.propagation-rns"
    ];

    certs."${services_domain}" = {
      domain = "*.${services_domain}";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1";
      environmentFile = "/etc/acme/cloudflare-env";
    };
  };

  # Create environment file for Cloudflare credentials
  environment.etc."acme/cloudflare-env" = {
    text = ''
      CLOUDFLARE_DNS_API_TOKEN_FILE=${config.services.onepassword-secrets.secretPaths.cloudflareDnsApiToken}
      CLOUDFLARE_ZONE_API_TOKEN_FILE=${config.services.onepassword-secrets.secretPaths.cloudflareZoneApiToken}
    '';
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
  networking.firewall.trustedInterfaces = [ "br-+" ];

  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
