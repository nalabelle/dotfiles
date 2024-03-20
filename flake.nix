{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    devshell.url = "github:numtide/devshell";
  };
  outputs = inputs @ {nixpkgs, devshell, ...}: let
    overlays = [ devshell.overlays.default ];
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system:
        function (import nixpkgs {
          inherit system overlays;
          # config.allowUnfree = true;
        }));
  in {
    packages = forAllSystems (pkgs: {
      default = pkgs.devshell.mkShell {
        imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
      };
    });
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {};
    overlays.default = final: prev: {};
  };
}
