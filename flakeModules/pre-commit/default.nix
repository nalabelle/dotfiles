# Pre-commit hooks flake module that provides a standard set of git hooks
# for code quality and consistency.
current-flake:
{
  lib,
  flake-parts-lib,
  ...
}: # This is the producer flake, the source for the module
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib)
    mkOption
    types
    ;
  #  inherit (git-hooks-lib) flakeModule;
in
{
  imports = [
    current-flake.inputs.git-hooks.flakeModule
  ];
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
              installationScript = lib.mkOption {
                type = types.str;
                default = ''
                  ${config.pre-commit.installationScript}
                  echo "Pre-commit environment loaded"
                '';
                description = "Pre-commit installation script";
              };
              devShell = mkOption {
                type = types.package;
                description = "A development shell with pre-commit installed and setup.";
              };
            };
          };
        };
        config = {
          pre-commit-defaults.enable = lib.mkDefault true;
          pre-commit-defaults.devShell = pkgs.mkShell {
            nativeBuildInputs = config.pre-commit.settings.enabledPackages;
            shellHook = config.pre-commit-defaults.installationScript;
          };

          formatter = lib.optionalAttrs config.pre-commit-defaults.enable (
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
                nixfmt-rfc-style.enable = lib.mkDefault true;

                # Custom hooks with inline definitions
                # Source: https://github.com/jumanjihouse/pre-commit-hooks
                forbid-binary = lib.mkDefault {
                  enable = true;
                  name = "forbid-binary";
                  description = "Forbid binary files from being committed";
                  entry = "${pkgs.writeShellScript "forbid-binary" ''
                    #!/usr/bin/env sh

                    ################################################################################
                    # Copyright (c) 2018 Paul Morgan

                    #   Permission is hereby granted, free of charge, to any person obtaining a copy
                    #   of this software and associated documentation files (the "Software"), to deal
                    #   in the Software without restriction, including without limitation the rights
                    #   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                    #   copies of the Software, and to permit persons to whom the Software is
                    #   furnished to do so, subject to the following conditions:

                    #   The above copyright notice and this permission notice shall be included in
                    #   all copies or substantial portions of the Software.

                    #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                    #   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                    #   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                    #   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                    #   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                    #   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
                    #   THE SOFTWARE.
                    ################################################################################

                    set -eu

                    ################################################################################
                    # Forbid binary files.
                    # pre-commit uses the "identify" pure python library to detect binary files.
                    ################################################################################

                    if [ $# -gt 0 ]; then
                      for filename in "''${@}"; do
                        echo "[ERROR] ''${filename} appears to be a binary file"
                      done
                      exit 1
                    fi
                  ''}";
                  language = "script";
                  types = [ "binary" ];
                };

                script-must-have-extension = lib.mkDefault {
                  enable = true;
                  name = "script-must-have-extension";
                  description = "Non-executable shell script filename ends in .sh";
                  entry = "${pkgs.writeShellScript "script-must-have-extension" ''
                    #!/usr/bin/env bash

                    ################################################################################
                    # Copyright (c) 2018 Paul Morgan

                    #   Permission is hereby granted, free of charge, to any person obtaining a copy
                    #   of this software and associated documentation files (the "Software"), to deal
                    #   in the Software without restriction, including without limitation the rights
                    #   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                    #   copies of the Software, and to permit persons to whom the Software is
                    #   furnished to do so, subject to the following conditions:

                    #   The above copyright notice and this permission notice shall be included in
                    #   all copies or substantial portions of the Software.

                    #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                    #   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                    #   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                    #   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                    #   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                    #   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
                    #   THE SOFTWARE.
                    ################################################################################

                    set -eEu
                    set -o pipefail

                    ################################################################################
                    # Fail if any shell script filename does not have a ".sh" extension.
                    #
                    # pre-commit uses the "identify" pure python library to detect shell files.
                    ################################################################################

                    declare -i RC=0

                    has_sh_extension() {
                      [[ "$(basename "''${1}")" != "$(basename "''${1}" .sh)" ]]
                    }

                    for filename in "''${@}"; do
                      if has_sh_extension "''${filename}"; then
                        echo "[OK]    ''${filename}"
                      else
                        echo "[ERROR] ''${filename} lacks the required .sh extension"
                        RC=1
                      fi
                    done

                    exit $RC
                  ''}";
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
                  entry = "${pkgs.writeShellScript "script-must-not-have-extension" ''
                    #!/usr/bin/env bash

                    ################################################################################
                    # Copyright (c) 2018 Paul Morgan

                    #   Permission is hereby granted, free of charge, to any person obtaining a copy
                    #   of this software and associated documentation files (the "Software"), to deal
                    #   in the Software without restriction, including without limitation the rights
                    #   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                    #   copies of the Software, and to permit persons to whom the Software is
                    #   furnished to do so, subject to the following conditions:

                    #   The above copyright notice and this permission notice shall be included in
                    #   all copies or substantial portions of the Software.

                    #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                    #   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                    #   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                    #   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                    #   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                    #   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
                    #   THE SOFTWARE.
                    ################################################################################

                    set -eEu
                    set -o pipefail

                    ################################################################################
                    # Fail if any shell script filename has an extension.
                    #
                    # pre-commit uses the "identify" pure python library to detect shell files.
                    ################################################################################

                    declare -i RC=0

                    has_sh_extension() {
                      [[ "$(basename "''${1}")" != "$(basename "''${1}" .sh)" ]]
                    }

                    for filename in "''${@}"; do
                      if has_sh_extension "''${filename}"; then
                        echo "[ERROR] ''${filename} has an extension but should not"
                        RC=1
                      else
                        echo "[OK]    ''${filename}"
                      fi
                    done

                    exit $RC
                  ''}";
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
