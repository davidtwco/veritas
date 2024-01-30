{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.gitui;
in
{
  options.veritas.configs.gitui = {
    enable = mkEnableOption "gitui configuration";
  };

  config = mkIf cfg.enable {
    programs.gitui = {
      enable = true;
      keyConfig = builtins.readFile "${config.programs.gitui.package.src}/vim_style_key_config.ron";
      theme = ''
        (
          selection_fg: Some(LightYellow),
          selection_bg: Some(Reset),

          command_fg: Some(Gray),
          cmdbar_bg: Some(Reset),
          cmdbar_extra_lines_bg: Some(Reset),

          push_gauge_fg: Some(LightBlue),
          push_gauge_bg: Some(Reset),
        )
      '';
    };  
  };
}
