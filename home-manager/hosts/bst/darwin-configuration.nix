{ pkgs, inputs, hostname, ... }: {
  homebrew = {
    taps = [ "stacklok/tap" ];

    brews = [ "thv" "mcpm" ];

    casks = [
      "docker" # docker-desktop
      "syncthing"
      "tailscale"
    ];
  };
}
