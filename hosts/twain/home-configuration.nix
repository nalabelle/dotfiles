{ config, pkgs, inputs, lib, ... }:

let
  # Read base MCP settings (same logic as home/vscode.nix)
  baseSettings = lib.importJSON ../../config/vscode/kilocode-mcp-settings.json;

  # Merge base settings with host-specific MCP servers
  mergedSettings = lib.recursiveUpdate baseSettings {
    mcpServers = config.vscode.hostMcpServers;
  };

  # Create the settings file content with pretty JSON formatting
  settingsFile = pkgs.runCommand "mcp_settings.json" { } ''
    echo '${
      lib.generators.toJSON { } mergedSettings
    }' | ${pkgs.jq}/bin/jq '.' > $out
  '';
in {
  # VSCode tunnel service configuration
  systemd.user.services.vscode-tunnel = {
    Unit = {
      Description = "VS Code Tunnel Service";
      After = "network.target";
    };

    Service = {
      Type = "simple";
      Environment = [
        "USER=%u"
        "LOGNAME=%u"
        "HOME=%h"
        "SHELL=/usr/bin/zsh"
        "TERM=xterm-256color"
        "XDG_RUNTIME_DIR=/run/user/1000"
        "FZF_TMUX=1"
        "TMUX_TMPDIR=/run/user/1000"
        "XDG_CACHE_HOME=%h/.cache"
        "XDG_CONFIG_HOME=%h/.config"
        "XDG_DATA_HOME=%h/.local/share"
        "XDG_STATE_HOME=%h/.local/state"
        "EDITOR=vim"
        "PAGER=less"
        "LESSHISTSIZE=0"
        "KEYTIMEOUT=1"
        "STARSHIP_SHELL=zsh"
        "DIRENV_DIR=-%h"
        "DIRENV_FILE=%h/.envrc"
        "PATH=%h/.cache/.bun/bin:%h/.local/share/../bin:%h/.nix-profile/bin:%h/.local/bin:%h/.homesick/repos/dotfiles/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
      ];
      ExecStart =
        "${config.programs.vscode.package}/bin/code tunnel --accept-server-license-terms";
      Restart = "on-failure";
      RestartSec = "90s";
    };

    Install = { WantedBy = [ "default.target" ]; };
  };

  # VSCode specific configuration
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  # Enable SSH for GitHub authentication
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
    '';
  };

  # Ensure proper file permissions for VS Code Server
  # home.file.".vscode-server".recursive = true; # Commenting out as we don't need this

  # Disable the standard XDG config file (not used on this machine)
  xdg.configFile."Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json".enable =
    false;

  # VS Code Server MCP settings (uses the same settings file logic as main vscode.nix)
  home.file.".vscode-server/data/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json" =
    {
      source = settingsFile;
    };

  # Configure home-manager auto-upgrade for flakes
  systemd.user.services.home-manager-auto-upgrade = {
    Service = {
      Environment = "PATH=/run/current-system/sw/bin";
      ExecStart = lib.mkForce
        "${pkgs.home-manager}/bin/home-manager switch --flake .#${config.home.username}@twain";
    };
  };
}
