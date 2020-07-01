{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.alacritty;
in
{
  options.veritas.configs.alacritty.enable = mkEnableOption "alacritty configuration";

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        colors = with config.veritas.profiles.common.colourScheme; {
          primary = {
            background = "0x${background}";
            foreground = "0x${foreground}";
          };
          normal = {
            black = "0x${black}";
            red = "0x${red}";
            green = "0x${green}";
            yellow = "0x${yellow}";
            blue = "0x${blue}";
            magenta = "0x${magenta}";
            cyan = "0x${cyan}";
            white = "0x${white}";
          };
          bright = {
            black = "0x${brightBlack}";
            red = "0x${brightRed}";
            green = "0x${brightGreen}";
            yellow = "0x${brightYellow}";
            blue = "0x${brightBlue}";
            magenta = "0x${brightMagenta}";
            cyan = "0x${brightCyan}";
            white = "0x${brightWhite}";
          };
        };
        font = {
          normal = {
            family = "Iosevka";
            style = "Regular";
          };
          bold = {
            family = "Iosevka";
            style = "Bold";
          };
          italic = {
            family = "Iosevka";
            style = "Italic";
          };
          size = 10;
        };
        key_bindings = [
          { key = "Insert"; mods = "Shift"; action = "Paste"; }
        ];
        scrolling.history = 50000;
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
