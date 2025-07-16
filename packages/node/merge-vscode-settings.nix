{ pkgs }:

pkgs.buildNpmPackage {
  pname = "merge-vscode-settings";
  version = "1.0.0";

  src = ./merge-vscode-settings;

  npmDepsHash = "sha256-I2C34njpbjuWj7EVeUAuxqy2DYNkqlEr7auV8k3Cu9U=";

  dontNpmBuild = true;
}
