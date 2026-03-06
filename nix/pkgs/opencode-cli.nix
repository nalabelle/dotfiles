# OpenCode CLI - installed via npx for automatic Renovate version tracking
{
  lib,
  stdenv,
  writeShellApplication,
  nodejs_24,
  ...
}:
let
  # renovate: datasource=npm depName=opencode-ai versioning=npm
  version = "1.2.20";
in
writeShellApplication {
  name = "opencode";
  runtimeInputs = [ nodejs_24 ];
  text = ''
    export NPM_CONFIG_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/opencode-cli/npm-cache"
    export NPM_CONFIG_PREFIX="''${XDG_CACHE_HOME:-$HOME/.cache}/opencode-cli/npm-prefix"
    mkdir -p "$NPM_CONFIG_CACHE" "$NPM_CONFIG_PREFIX/lib" "$NPM_CONFIG_PREFIX/bin"
    npx --yes opencode-ai@${version} "$@"
  '';

  meta = {
    description = "OpenCode CLI";
    homepage = "https://opencode.ai";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
