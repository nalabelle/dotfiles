{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-autosuggestions
  ];

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

    initContent = ''
      # Globbing options (no built-in Home Manager support)
      setopt nocaseglob
      setopt extendedglob
      setopt globdots
      setopt no_nomatch

      # Corrections (no built-in Home Manager support)
      setopt correct

      # History verify (supplement existing history config)
      setopt histverify

      # Vi mode key bindings (supplement built-in vi mode)
      bindkey -v '^?' backward-delete-char
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down
    '';
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

      palettes.xoria = {
        dark_grey = "248";
      };

      character = {
        vimcmd_symbol = "[N](bold green)";
        vimcmd_visual_symbol = "[V](bold yellow)";
      };

      line_break = {
        disabled = true;
      };

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

      fill = {
        symbol = " ";
      };

      nix_shell = {
        format = "[$symbol$state( \\($name\\))]($style) ";
        symbol = "❆ ";
        impure_msg = "";
      };

      rust = {
        format = "[$symbol($version )]($style)";
      };

      env_var.PROMPT_ENV = {
        style = "grey dimmed";
        format = "[\\($env_value\\)]($style) ";
      };
    };
  };

}
