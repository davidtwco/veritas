{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.xresources;
  colours = config.veritas.profiles.common.colourScheme;
in
{
  options.veritas.configs.xresources.enable = mkEnableOption "xresources configuration";

  config = mkIf cfg.enable {
    xresources.properties = with colours; {
      # Hybrid colour scheme.
      "*background" = "#${background}";
      "*foreground" = "#${foreground}";
      "*cursorColor" = "#${cursor}";
      "*color0" = "#${black}";
      "*color1" = "#${red}";
      "*color2" = "#${green}";
      "*color3" = "#${yellow}";
      "*color4" = "#${blue}";
      "*color5" = "#${magenta}";
      "*color6" = "#${cyan}";
      "*color7" = "#${white}";
      "*color8" = "#${brightBlack}";
      "*color9" = "#${brightRed}";
      "*color10" = "#${brightGreen}";
      "*color11" = "#${brightYellow}";
      "*color12" = "#${brightBlue}";
      "*color13" = "#${brightMagenta}";
      "*color14" = "#${brightCyan}";
      "*color15" = "#${brightWhite}";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
