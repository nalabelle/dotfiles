# OpenCode wrapper with credential loading
{ pkgs, ... }:
{
  # Wrapped CLI binary that sources credentials before launching
  opencode-wrapped = pkgs.writeShellApplication {
    name = "opencode";
    runtimeInputs = [ ];
    text = ''
      if [ -f "$HOME/.config/credentials/opencode.env" ]; then
        set -a
        # shellcheck source=/dev/null
        . "$HOME/.config/credentials/opencode.env"
        set +a
      fi
      exec ${pkgs.opencode}/bin/opencode "$@"
    '';
  };
}
