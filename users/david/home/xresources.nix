{ config, pkgs, ... }:

# This file contains the configuration for Xresources.
let
  colours = config.veritas.david.colourScheme.basic;
in
{
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
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
