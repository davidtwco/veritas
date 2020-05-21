{ config, pkgs, ... }:

# This file contains the configuration for polybar.
let
  barName = "veritas";
  colours = config.veritas.david.colourScheme;
  # Define a helper function for creating short shell scripts that have some colours available
  # to them.
  mkBarScript = module: contents:
    let
      name = "veritas-polybar-${module}";
      dir = pkgs.writeScriptBin name (
        with pkgs; ''
          #! ${runtimeShell} -e
          xres() {
            ${xlibs.xrdb}/bin/xrdb -query | \
            ${gnugrep}/bin/grep -w $1 | \
            ${gawk}/bin/awk '{print $2}'
          }

          foreground="$(xres color15)"
          muted="$(xres color7)"

          ${contents}
        ''
      );
    in
    "${dir}/bin/${name}";
in
{
  services.polybar = {
    config = {
      "bar/${barName}" = {
        "bottom" = false;
        # Bar is transparent.
        "background" = "#00000000";
        "font-0" =
          let
            defaultFontSize = 12;
            fontSize = builtins.toString (defaultFontSize * config.veritas.david.dotfiles.uiScale);
          in
          "Iosevka:style=Bold:size=${fontSize}";
        "height" = "1.5%";
        "locale" = config.home.language.base;
        # Modules are one-and-a-half spaces apart.
        "module-margin" = "1.5";
        # Add some padding.
        "padding" = "1";
        # Information is on the left, i3 workspaces on the right.
        "modules-left" = [ "date" "time" "load" "cpu" "memory" "volume" ];
        "modules-right" = [ "i3" ];
        # Display on the monitor from the environment, provided by loop in
        # `services.polybar.script`.
        "monitor" = "\${env:MONITOR:}";
        # Use border to add some spacing from the edge of the screen.
        "border-top-size" = "15";
        "border-bottom-size" = "2";
        "border-right-size" = "10";
        "border-left-size" = "10";
        "border-color" = "0";
      };
      "module/cpu" = {
        type = "custom/script";
        interval = "3.0";
        exec = mkBarScript "cpu" (
          with pkgs; ''
            echo "%{F$muted}cpu %{F$foreground}$( \
              ${sysstat}/bin/mpstat | ${gawk}/bin/awk '$12 ~ /[0-9.]+/ { print 100 - $12"%" }')"
          ''
        );
      };
      "module/load" = {
        type = "custom/script";
        interval = "1.0";
        exec = mkBarScript "load" (
          with pkgs; ''
            echo "%{F$muted}load %{F$foreground}$( \
              ${coreutils}/bin/cat /proc/loadavg | ${coreutils}/bin/cut -d' ' -f1)"
          ''
        );
      };
      "module/date" = {
        type = "custom/script";
        interval = "3.0";
        exec = mkBarScript "date" (
          with pkgs; ''
            echo "%{F$muted}date %{F$foreground}$( \
              ${coreutils}/bin/date +"%a, %d %b" | ${coreutils}/bin/tr A-Z a-z)"
          ''
        );
      };
      "module/time" = {
        type = "custom/script";
        interval = "1.0";
        exec = mkBarScript "time" (
          ''
            echo "%{F$muted}time %{F$foreground}$(${pkgs.coreutils}/bin/date +%H:%M:%S)"
          ''
        );
      };
      "module/i3" = {
        "type" = "internal/i3";
        "enable-click" = true;
        "enable-scroll" = true;
        "index-sort" = true;
        "label-focused-foreground" = "#${colours.basic.brightWhite}";
        "label-unfocused-foreground" = "#${colours.basic.black}";
        "label-visible-foreground" = "#${colours.basic.white}";
        "label-urgent-foreground" = "#${colours.basic.red}";
      };
      "module/memory" = {
        type = "custom/script";
        interval = "3.0";
        exec = mkBarScript "mem" (
          with pkgs; ''
            memory() {
              ${procps}/bin/free -h --si | ${gnugrep}/bin/grep Mem | ${gawk}/bin/awk "{print \$$1}"
            }

            echo "%{F$muted}mem %{F$foreground}$(memory 3)/$(memory 2)"
          ''
        );
      };
      "module/volume" = {
        type = "custom/script";
        interval = "0.01";
        exec = mkBarScript "volume-status" (
          with pkgs; ''
            if [[ $(${alsaUtils}/bin/amixer get Master | \
                    ${gnugrep}/bin/grep 'Right' | \
                    ${gawk}/bin/awk -F'[][] ' '{ print $2 }' | \
                    ${coreutils}/bin/tr -d '\n') = "[on]" ]]; then
              volume=$(${alsaUtils}/bin/amixer get Master | \
                       ${gnugrep}/bin/grep 'Right' | \
                       ${gawk}/bin/awk -F'[][]' '{ print $2 }' | \
                       ${coreutils}/bin/tr -d '\n')
              echo -ne "%{F$muted}vol %{F$foreground}$volume"
            else
              echo -ne "%{F$muted}vol %{F$foreground}muted"
            fi
          ''
        );
        click-left = mkBarScript "volume-toggle" (
          with pkgs; ''
            ${alsaUtils}/bin/amixer sset Master toggle
          ''
        );
        scroll-up = mkBarScript "volume-up" (
          with pkgs; ''
            ${alsaUtils}/bin/amixer sset Master 2%+
          ''
        );
        scroll-down = mkBarScript "volume-down" (
          with pkgs; ''
            ${alsaUtils}/bin/amixer sset Master 2%-
          ''
        );
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
