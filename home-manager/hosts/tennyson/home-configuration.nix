{ pkgs, inputs, ... }: {
  xdg.configFile = {
    "mcpm/config.json".source = ../../config/mcpm/config.json;
    "mcpm/profiles.json".source = ../../config/mcpm/profiles.json;
  }
};