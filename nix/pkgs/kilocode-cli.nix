# KiloCode CLI - installed via npx for automatic Renovate version tracking
{
  lib,
  stdenv,
  writeShellApplication,
  nodejs_24,
  ...
}:
let
  # renovate: datasource=npm depName=@kilocode/cli-linux-x64 versioning=npm
  version = "7.0.27";

  packageName =
    if stdenv.isLinux && stdenv.hostPlatform.isx86_64 then
      "@kilocode/cli-linux-x64"
    else if stdenv.isDarwin && stdenv.hostPlatform.isAarch64 then
      "@kilocode/cli-darwin-arm64"
    else
      throw "Unsupported platform: ${stdenv.hostPlatform.system}";
in
writeShellApplication {
  name = "kilo";
  runtimeInputs = [ nodejs_24 ];
  text = ''
    export NPM_CONFIG_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/kilocode-cli/npm-cache"
    export NPM_CONFIG_PREFIX="''${XDG_CACHE_HOME:-$HOME/.cache}/kilocode-cli/npm-prefix"
    mkdir -p "$NPM_CONFIG_CACHE" "$NPM_CONFIG_PREFIX/lib" "$NPM_CONFIG_PREFIX/bin"
    npx --yes ${packageName}@${version} "$@"
  '';

  meta = {
    description = "Kilo Code CLI";
    homepage = "https://kilocode.ai/cli";
    license = lib.licenses.mit;
    mainProgram = "kilo";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
