# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# sudo nixos-rebuild switch --flake ~/git/dotfiles#chandler

{
  config,
  modulesPath,
  pkgs,
  ...
}:
let
  services_domain = "oops.city";
in
{
  imports = [
    # Include the results of the hardware scan.
    # sudo nixos-generate-config --dir ~/git/dotfiles/hosts/twain
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  nix.settings = {
    experimental-features = "nix-command flakes";
    sandbox = false;
  };
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };

  networking.hostName = "twain"; # Define your hostname.
  networking.hostId = "a7e23f63";

  # Select internationalisation properties.
  time.timeZone = "Etc/UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Run dynamic binaries
  programs.nix-ld.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
    };
  };

  # Configure root user SSH authorized keys
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdghZWKTk7678RA/Vt4LMktDd47yLjYSgLalXEP85sh root@std"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFKJHY+snv++lECkHqrO1TU+iy+UNz+4HSpINyScsMR root@forgejo"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfU1p/YuQOkLEJTH3HuxX8tAMu2P8gxh2zo2UN1tUjL root@shelley"
  ];

  # Configure 1Password secrets for system services
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = [
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
    };
  };

  # Enable nginx web server with reverse proxy for Forgejo
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
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
