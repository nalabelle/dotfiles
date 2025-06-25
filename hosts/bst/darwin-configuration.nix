{ pkgs, inputs, hostname, ... }: {
  ids.gids.nixbld = 30000;
  homebrew = {
    taps = [ "withgraphite/tap" ];

    brews = [ "graphite" ];

    casks = [ "dbeaver-community" "linear-linear" ];
  };
}
