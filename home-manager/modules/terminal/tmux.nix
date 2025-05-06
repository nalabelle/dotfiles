{ config, lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    shortcut = "a";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    sensibleOnTop = true;
    # This causes some problems...
    # https://github.com/tmux/tmux/pull/4411
    # https://github.com/tmux/tmux/commit/817b621d2078137b4ddea78835f609a9d7bac339
    # https://github.com/tmux-plugins/tmux-sensible/issues/61
    escapeTime = 500;

    plugins = with pkgs; [
      tmuxPlugins.cpu
      tmuxPlugins.pain-control
      tmuxPlugins.prefix-highlight
      tmuxPlugins.yank
    ];

    terminal = "screen-256color-bce-s";
    #check infocmp screen-256color-bce-s
    #check infocmp screen-256color-bce

    extraConfig = ''
      # Don't move around panes with arrow keys
      unbind Left
      unbind Down
      unbind Up
      unbind Right

      # yank and visual selection in the tmux buffer
      #bind -t vi-copy v begin-selection
      #bind -t vi-copy y copy-selection

      # prefix, S to send a pane to a window
      bind-key S choose-window "join-pane -t "%%""

      # prefix, C to clear a pane and its history
      unbind C
      bind-key C send-keys -R "Escape" C-l \; clear-history
      bind-key O customize-mode -Z

      # styles
      set -g status-style bg=black,fg=white
      set -g pane-border-style fg=blue,bg=default
      set -g pane-active-border-style fg=green,bg=default

      # status-left
      set -g status-left '#{?pane_in_mode,#{s/copy.+/#[fg=black,bg=red]/:pane_mode} #S ,#[fg=black,bg=green] #S }#{prefix_highlight}'
      set -g @prefix_highlight_fg 'black,bold'
      set -g @prefix_highlight_bg 'yellow'

      # status-window
      set -g window-status-format ' #I>#W#F '
      set -g window-status-current-format ' #I>#W#F '
      set -ag window-status-current-style fg=black,bg=blue

      # status-right
      set -ag status-right-style dim
      set -g status-right-length 80
      set -g status-right '#{ram_fg_color}#{ram_percentage}#[fg=default] #{cpu_fg_color}#{cpu_percentage}#[fg=default] #(status-getload.sh)/#(status-getcpu.sh) #[bg=colour236,fg=default] %H:%M #[bg=default,fg=default] #h '
      set -g status-interval 10
    '';
  };
}
