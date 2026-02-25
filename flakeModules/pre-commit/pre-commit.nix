# Pre-commit hooks flake module implementation
# This contains the actual pre-commit configuration and hooks.
{
  lib,
  flake-parts-lib,
  jumanjihouse-hooks,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib)
    mkOption
    types
    ;
in
{
  # git-hooks.flakeModule is imported by the wrapper in flake.nix

  options = {
    perSystem = mkPerSystemOption (
      {
        config,
        pkgs,
        ...
      }:
      {
        options.pre-commit-defaults = mkOption {
          type = types.submodule {
            options = {
              enable = lib.mkOption {
                type = types.bool;
                default = true;
                example = true;
                description = "Enable pre-commit defaults";
              };
              enableFormatter = lib.mkOption {
                type = types.bool;
                default = false;
                example = true;
                description = "Enable formatter (runs pre-commit in nix flake check)";
              };
              installationScript = lib.mkOption {
                type = types.str;
                default = ''
                  ${config.pre-commit.installationScript}
                  echo "Pre-commit environment loaded"
                '';
                description = "Pre-commit installation script";
              };
            };
          };
        };
        config = {
          pre-commit-defaults.enable = lib.mkDefault true;

          devShells.pre-commit = pkgs.mkShell {
            nativeBuildInputs = config.pre-commit.settings.enabledPackages ++ [
              config.pre-commit.settings.package
            ];
            shellHook = config.pre-commit-defaults.installationScript;
          };

          formatter = lib.mkIf config.pre-commit-defaults.enableFormatter (
            let
              script = ''
                ${config.pre-commit.settings.package}/bin/pre-commit run --all-files --config ${config.pre-commit.settings.configFile}
              '';
            in
            pkgs.writeShellScriptBin "pre-commit-run" script
          );
          pre-commit = lib.mkIf config.pre-commit-defaults.enable {
            settings = {
              hooks = {
                # File integrity and format hooks
                fix-byte-order-marker.enable = lib.mkDefault true;
                check-case-conflicts.enable = lib.mkDefault true;
                check-executables-have-shebangs.enable = lib.mkDefault true;
                check-json.enable = lib.mkDefault true;
                check-merge-conflicts.enable = lib.mkDefault true;
                check-shebang-scripts-are-executable = lib.mkDefault {
                  enable = true;
                  excludes = [ "\.j2$" ];
                };
                check-symlinks.enable = lib.mkDefault true;
                check-toml.enable = lib.mkDefault true;
                check-xml.enable = lib.mkDefault true;
                check-yaml = lib.mkDefault {
                  enable = true;
                  args = [ "--allow-multiple-documents" ];
                };
                end-of-file-fixer.enable = lib.mkDefault true;
                mixed-line-endings.enable = lib.mkDefault true;
                trim-trailing-whitespace.enable = lib.mkDefault true;

                # Language-specific hooks
                shellcheck.enable = lib.mkDefault true;
                nixfmt.enable = lib.mkDefault true;

                # Custom hooks from jumanjihouse/pre-commit-hooks
                # Source: https://github.com/jumanjihouse/pre-commit-hooks
                forbid-binary = lib.mkDefault {
                  enable = true;
                  name = "forbid-binary";
                  description = "Forbid binary files from being committed";
                  entry = "${jumanjihouse-hooks}/pre_commit_hooks/forbid-binary";
                  language = "script";
                  types = [ "binary" ];
                };

                script-must-have-extension = lib.mkDefault {
                  enable = true;
                  name = "script-must-have-extension";
                  description = "Non-executable shell script filename ends in .sh";
                  entry = "${jumanjihouse-hooks}/pre_commit_hooks/script_must_have_extension";
                  language = "script";
                  types = [
                    "shell"
                    "non-executable"
                  ];
                  excludes = [ "\.envrc$" ];
                };

                script-must-not-have-extension = lib.mkDefault {
                  enable = true;
                  name = "script-must-not-have-extension";
                  description = "Executable shell script omits the filename extension";
                  entry = "${jumanjihouse-hooks}/pre_commit_hooks/script_must_not_have_extension";
                  language = "script";
                  types = [
                    "shell"
                    "executable"
                  ];
                };

              };
            };
          };
        };
      }
    );
  };

}
