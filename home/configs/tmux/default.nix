{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.tmux;

  extraConfig = pkgs.substituteAll {
    src = ./tmux.conf;
    # This script prints the username and hostname of a host if there is an active SSH connection,
    # otherwise, it prints nothing.
    statuslineSsh = pkgs.writeScriptBin "tmux-statusline-ssh" ''
      #! ${pkgs.runtimeShell} -e
      ${pkgs.tmux}/bin/tmux show-environment -g SSH_CONNECTION &>/dev/null
      if [ $? -eq 0 ]; then
        printf "`${pkgs.coreutils}/bin/whoami`@`${pkgs.inetutils}/bin/hostname`"
      fi
    '';
  };
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
      extraConfig = "source-file ${extraConfig}";
      keyMode = "vi";
      plugins = with pkgs; [
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

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
