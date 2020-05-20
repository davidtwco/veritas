{ config, pkgs, ... }:

# This file contains the configuration for tmux.

let
  # This script prints the username and hostname of a host if there is an
  # active SSH connection, otherwise, it prints nothing.
  statuslineSsh = let
    name = "tmux-statusline-ssh";
    dir = pkgs.writeScriptBin name ''
      #! ${pkgs.runtimeShell} -e
      ${pkgs.unstable.tmux}/bin/tmux show-environment -g SSH_CONNECTION &>/dev/null
      if [ $? -eq 0 ]; then
        printf "`${pkgs.coreutils}/bin/whoami`@`${pkgs.inetutils}/bin/hostname`"
      fi
    '';
  in
    "${dir}/bin/${name}";
in
{
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

      # Change word separators to better match Vim.
      set -g word-separators "<>(){}[]/'\";@*+,.-_=!£$%^&:#~?`¬|\\ "

      # Update these variables from the environment when attaching to tmux.
      set -g update-environment "SSH_AUTH_SOCK SSH_CLIENT SSH_CONNECTION DISPLAY LOCALE_ARCHIVE LANG LANGUAGE LC_ALL"

      # Use 24-bit colour.
      set -ga terminal-overrides ",xterm-256color:Tc"

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
    package = pkgs.unstable.tmux;
    plugins = with pkgs.unstable; [
      {
        plugin = tmuxPlugins.mkDerivation {
          # Script is named differently from the plugin.
          pluginName = "scroll_copy_mode";
          version = "aa59077";
          src = (import ../../../nix/sources.nix).tmux-better-mouse-mode;
        };
      }
      { plugin = tmuxPlugins.fzf-tmux-url; }
      { plugin = tmuxPlugins.logging; }
      { plugin = tmuxPlugins.copycat; }
      { plugin = tmuxPlugins.vim-tmux-navigator; }
      { plugin = tmuxPlugins.yank; }
    ];
    secureSocket = !config.veritas.david.dotfiles.isWsl;
    sensibleOnTop = true;
    terminal = "xterm-256color";
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
