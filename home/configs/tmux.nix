{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.tmux;

  # This script prints the username and hostname of a host if there is an active SSH connection,
  # otherwise, it prints nothing.
  statuslineSsh =
    let
      name = "tmux-statusline-ssh";
      dir = pkgs.writeScriptBin name ''
        #! ${pkgs.runtimeShell} -e
        ${pkgs.tmux}/bin/tmux show-environment -g SSH_CONNECTION &>/dev/null
        if [ $? -eq 0 ]; then
          printf "`${pkgs.coreutils}/bin/whoami`@`${pkgs.inetutils}/bin/hostname`"
        fi
      '';
    in
    "${dir}/bin/${name}";
in
{
  options.veritas.configs.tmux = {
    enable = mkEnableOption "tmux configuration";

    wslCompatibility = mkOption {
      type = types.bool;
      default = false;
      description = "Do not use a runtime directory for the tmux socket, necessary for WSL 1.";
    };
  };

  config = mkIf cfg.enable {
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
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.mkDerivation {
            pluginName = "scroll_copy_mode";
            version = "aa59077";
            src = pkgs.fetchFromGitHub {
              owner = "NHDaly";
              repo = "tmux-better-mouse-mode";
              rev = "aa59077c635ab21b251bd8cb4dc24c415e64a58e";
              sha256 = "06346ih3hzwszhkj25g4xv5av7292s6sdbrdpx39p0n3kgf5mwww";
            };
          };
        }
        { plugin = tmuxPlugins.fzf-tmux-url; }
        { plugin = tmuxPlugins.logging; }
        { plugin = tmuxPlugins.copycat; }
        { plugin = tmuxPlugins.vim-tmux-navigator; }
        { plugin = tmuxPlugins.yank; }
      ];
      secureSocket = !cfg.wslCompatibility;
      sensibleOnTop = true;
      terminal = "xterm-256color";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
