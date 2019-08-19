{ config, pkgs, ... }:

let
  # This script prints the username and hostname of a host if there is an
  # active SSH connection, otherwise, it prints nothing.
  statuslineSsh = let
    name = "tmux-statusline-ssh";
    dir = pkgs.writeScriptBin name ''
      #! ${pkgs.runtimeShell} -e
      ${pkgs.tmux}/bin/tmux show-environment -g SSH_CONNECTION &>/dev/null
      if [ $? -eq 0 ]; then
        printf "`${pkgs.coreutils}/bin/whoami`@`${pkgs.inetutils}/bin/hostname`"
      fi
    '';
  in "${dir}/bin/${name}";
in {
  programs.tmux = {
    customPaneNavigationAndResize = true;
    enable = true;
    escapeTime = 0;
    extraConfig = ''
      # Enable the mouse.
      set -g mouse on

      # Enable focus events.
      set -g focus-events on

      # Automatically rename window titles.
      setw -g automatic-rename on
      set -g set-titles on

      # Automatically renumber windows when a window is closed.
      set -g renumber-windows on

      # Better bindings for splitting panes.
      bind | split-window -h
      bind - split-window -v

      # Sync input between panes.
      bind S set-window-option synchronize-panes

      # Clear screen.
      bind C-l send-keys 'C-l'

      # Select windows.
      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      # Statusline
      set -g status-style fg=brightblack
      set -g status-justify left
      set -g status-left ' #S #{?client_prefix,#[fg=brightyellow]⬣ ,}'
      set -g status-left-length 60
      set -g status-right '#(${statuslineSsh}) #[fg=brightblack]%H:%M:%S '
      set -g status-right-length 60

      set -g message-style fg=white,bright

      set -g pane-active-border-style fg=white
      set -g pane-border-style fg=brightblack

      setw -g window-status-style fg=white
      setw -g window-status-format ' #W #{?pane_synchronized,#[fg=red]⬣ ,}#{?window_zoomed_flag,#[fg=blue]⬣ ,}'

      setw -g window-status-current-style fg=brightwhite
      setw -g window-status-current-format ' #W #{?pane_synchronized,#[fg=brightred]⬣ ,}#{?window_zoomed_flag,#[fg=brightblue]⬣ ,}'
    '';
    keyMode = "vi";
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.mkDerivation {
          pluginName = "better-mouse-mode";
          src = builtins.fetchGit {
            url = "https://github.com/NHDaly/tmux-better-mouse-mode.git";
            ref = "master";
            rev = "aa59077c635ab21b251bd8cb4dc24c415e64a58e";
          };
        };
      }
      { plugin = tmuxPlugins.fzf-tmux-url; }
      { plugin = tmuxPlugins.logging; }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
        '';
      }
      { plugin = tmuxPlugins.copycat; }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-save-shell-history 'on'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      { plugin = unstable.tmuxPlugins.vim-tmux-navigator; }
      { plugin = tmuxPlugins.yank; }
    ];
    sensibleOnTop = true;
  };
}
