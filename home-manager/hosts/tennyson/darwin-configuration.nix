{ pkgs, inputs, hostname, username, ... }: {
  #  {
  #  nixpkgs.overlays = [
  #    (final: prev: {
  #      # https://github.com/nix-community/home-manager/issues/1341#issuecomment-1468889352
  #      mkAlias = mkAlias.outputs.apps.${prev.system}.default.program;
  #    })
  #  ];
  #}

  homebrew = {
    taps = [ "stacklok/tap" ];

    brews = [ "thv" "mcpm" ];

    casks = [
      "android-ndk"
      "android-platform-tools"
      "android-studio"
      "docker" # docker-desktop
      "kopiaui"
      "syncthing"
      "tailscale"
    ];
  };
}
