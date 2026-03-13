{
  config,
  lib,
  pkgs,
  ...
}:

let
  deployScript = pkgs.writeShellApplication {
    name = "zed-deploy-config";
    runtimeInputs = [ ];
    text = builtins.readFile ./deploy-config;
  };
in
{
  home.activation.zedDeploy = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    ${deployScript}/bin/zed-deploy-config \
      "${./settings.jsonc}" \
      "${config.xdg.configHome}/zed/settings.json" \
      "${config.xdg.configHome}/zed" \
      30
  '';
}
