{ lib, inputs, nixpkgs, home-manager, vars, ... }:

{
  # Home Manager configurations
  aarch64-darwin = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { system = "aarch64-darwin"; };
    modules =
      [ ../modules { home.homeDirectory = "/Users/${vars.username}"; } ];
  };

  x86_64-linux = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { system = "x86_64-linux"; };
    modules = [ ../modules { home.homeDirectory = "/home/${vars.username}"; } ];
  };
}
