{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.tmux;
in
{
  options.veritas.configs.tmux.enable = mkEnableOption "tmux configuration";

  config = mkIf cfg.enable {
    programs.tmux = {
      customPaneNavigationAndResize = true;
      enable = true;
      escapeTime = 0;
      extraConfig = "source-file ${./tmux.conf}";
      keyMode = "vi";
      plugins = with pkgs; [
        { plugin = tmuxPlugins.fzf-tmux-url; }
        { plugin = tmuxPlugins.logging; }
        { plugin = tmuxPlugins.copycat; }
        { plugin = tmuxPlugins.vim-tmux-navigator; }
        { plugin = tmuxPlugins.yank; }
      ];
      sensibleOnTop = true;
      terminal = "xterm-256color";
    };
  };
}
