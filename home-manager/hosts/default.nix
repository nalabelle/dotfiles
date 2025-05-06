{ lib, inputs, nixpkgs, home-manager, darwin, vars, ... }:

{
  # NixOS configurations
  # This would contain your Linux system configurations
  x86_64-linux = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { system = "x86_64-linux"; };
    modules = [ ../modules { home.homeDirectory = "/home/${vars.username}"; } ];
  };
}
