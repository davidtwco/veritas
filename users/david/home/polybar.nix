{ config, pkgs, ... }:

# This file contains the configuration for polybar.

let
  barName = "veritas";
  colours = config.veritas.david.colourScheme;
in {
  services.polybar = {
    config = {
      "bar/${barName}" = {
        "background" = "#00000000";
        "bottom" = false;
        "font-0" = "Iosevka:size=12";
        "locale" = config.home.language.base;
        "module-margin" = "1";
        "modules-left" = [ "cpu" "memory" ];
        "modules-center" = [ "i3" ];
        "modules-right" = [ "date" ];
        "monitor" = "\${env:MONITOR:}";
        "padding" = "1";
        "tray-position" = "right";
      };
      "module/cpu" = {
        "type" = "internal/cpu";
        "interval" = "3";
        "label" = "CPU %percentage%%";
      };
      "module/date" = {
        "type" = "internal/date";
        "interval" = "1";
        "date" = "%Y-%m-%d%";
        "time" = "%H:%M:%S";
        "label" = "%date% %time%";
      };
      "module/i3" = {
        "type" = "internal/i3";
        "enable-click" = true;
        "enable-scroll" = true;
        "index-sort" = true;
        "label-focused-foreground" = "#${colours.basic.red}";
        "label-unfocused-foreground" = "#${colours.basic.black}";
        "label-visible-foreground" = "#${colours.basic.foreground}";
        "label-urgent-foreground" = "#${colours.basic.brightRed}";
      };
      "module/memory" = {
        "type" = "internal/memory";
        "interval" = "3";
        "label" = "RAM %gb_used%/%gb_total%";
      };
    };
    enable = true;
    package = pkgs.polybar.override {
      i3GapsSupport = true;
      alsaSupport = true;
      githubSupport = true;
    };
    script = ''
      # Run polybar on every connected monitor.
      for m in $(${pkgs.xlibs.xrandr}/bin/xrandr --query | \
                 ${pkgs.gnugrep}/bin/grep " connected" | \
                 ${pkgs.coreutils}/bin/cut -d" " -f1); do
        MONITOR=$m polybar --reload ${barName} &
      done
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
