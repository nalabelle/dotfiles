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
    brews = [ "mcpm" ];

    casks =
      [ "android-ndk" "android-platform-tools" "android-studio" "kopiaui" "obsidian" ];
  };
}
