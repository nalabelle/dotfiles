{ lib, inputs, nixpkgs, home-manager, darwin, mkAlias, vars, ... }:

{
  # Darwin configurations
  "tennyson" = darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      flakeInputs = inputs;
      username = vars.username;
      hostname = "tennyson";
    };
    modules = [
      ./darwin-configuration.nix
      ./host-users.nix
      ./tennyson-configuration.nix
      {
        nixpkgs.overlays = [
          (final: prev: {
            # https://github.com/nix-community/home-manager/issues/1341#issuecomment-1468889352
            mkAlias = mkAlias.outputs.apps.${prev.system}.default.program;
          })
        ];
      }
      home-manager.darwinModules.home-manager
      {
        # Pass special arguments to the Home Manager modules
        home-manager.extraSpecialArgs = { inherit inputs vars; };

        home-manager.users.${vars.username} = {
          imports = [ ../modules ../modules/systems/darwin ];
          home.homeDirectory = "/Users/${vars.username}";
          nixpkgs.config.allowUnfree =
            true; # Configure allowUnfree for Home Manager's pkgs
        };
      }
    ];
  };
}
