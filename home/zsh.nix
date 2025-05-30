{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-autosuggestions
  ];

  home.file.".config/zsh/options".source = ../zsh/options;
  home.file.".config/zsh/prompt".source = ../zsh/prompt;
  home.file.".config/zsh/imports".source = ../zsh/imports;
  home.file.".config/zsh/completions".source = ../zsh/completions;

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    autocd = true;
    enableCompletion = true;
    envExtra = ''
      skip_global_compinit=1
    '';

    # History
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      # How many commands in the history file
      save = 5000;
      # How many commands in session history
      size = 2000;
      append = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreDups = true;
      share = false;
    };

    historySubstringSearch.enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    completionInit = ''
      zstyle ':completion:*' cache-path ${config.xdg.cacheHome}/zsh/zcompcache
      autoload -Uz compinit
      compinit -d ${config.xdg.cacheHome}/zsh/zcompdump-$ZSH_VERSION
    '';

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        source ${config.xdg.configHome}/zsh/options;
        source ${config.xdg.configHome}/zsh/prompt;
        source ${config.xdg.configHome}/zsh/imports;
      '')

      ''
        # Source the completions file
        if [ -f "${config.xdg.configHome}/zsh/completions" ]; then
          source ${config.xdg.configHome}/zsh/completions;
        fi
      ''
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      add_newline = true;
      format = ''
        $time$fill$username$hostname
        $all
        ''${env_var.PROMPT_ENV}$character'';
      palette = "xoria";

      command_timeout = 1000;

      palettes.xoria = { dark_grey = "248"; };

      character = {
        vimcmd_symbol = "[N](bold green)";
        vimcmd_visual_symbol = "[V](bold yellow)";
      };

      line_break = { disabled = true; };

      time = {
        disabled = false;
        style = "dimmed dark_grey";
        format = "[$time]($style)";
        time_format = "%F %T%Z";
        utc_time_offset = "0";
      };

      username = {
        style_user = "dimmed dark_grey";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_symbol = "";
        style = "dimmed dark_grey";
        format = "[$ssh_symbol@$hostname]($style)";
      };

      fill = { symbol = " "; };

      nix_shell = {
        format = "[$symbol$state( \\($name\\))]($style) ";
        symbol = "❆ ";
        impure_msg = "";
      };

      rust = { format = "[$symbol($version )]($style)"; };

      env_var.PROMPT_ENV = {
        style = "grey dimmed";
        format = "[\\($env_value\\)]($style) ";
      };
    };
  };

}
