{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.xsession.windowManager.i3.config;

  modifier = config.xsession.windowManager.i3.config.modifier;
  workspaces = {
    one = "1";
    two = "2";
    three = "3";
    four = "4";
    five = "5";
    six = "6";
    seven = "7";
    eight = "8";
    nine = "9";
  };
in
{
  options.veritas.configs.i3 = {
    enable = mkEnableOption "i3 configuration";

    colourScheme = {
      highlight = mkOption {
        default = config.veritas.profiles.common.colourScheme.red;
        description = "Define the colour for i3's highlight.";
        example = "FFFFFF";
        type = types.str;
      };

      highlightBright = mkOption {
        default = config.veritas.profiles.common.colourScheme.brightRed;
        description = "Define the colour for i3's bright highlight.";
        example = "FFFFFF";
        type = types.str;
      };
    };

    fontSize = mkOption {
      type = types.float;
      default = 10;
      description = "Font size used in i3.";
    };
  };

  config = mkIf config.veritas.configs.i3.enable {
    home.packages = with pkgs; [
      (
        writeScriptBin "i3-get-window-criteria" ''
          #! ${runtimeShell} -e
          match_int='[0-9][0-9]*'
          match_string='".*"'
          match_qstring='"[^"\\]*(\\.[^"\\]*)*"'

          {
              # Run `xwininfo`, get window ID.
              window_id=`${xorg.xwininfo}/bin/xwininfo -int | \
                         ${gnused}/bin/sed -nre "s/^xwininfo: Window id: ($match_int) .*$/\1/p"`
              echo "id=$window_id"

              # Run `xprop`, transform its output into i3 criteria. Handle fallback to
              # `WM_NAME` when `_NET_WM_NAME` isn't set
              ${xorg.xprop}/bin/xprop -id $window_id |
                  ${gnused}/bin/sed -nr \
                      -e "s/^WM_CLASS\(STRING\) = ($match_qstring), ($match_qstring)$/instance=\1\nclass=\3/p" \
                      -e "s/^WM_WINDOW_ROLE\(STRING\) = ($match_qstring)$/window_role=\1/p" \
                      -e "/^WM_NAME\(STRING\) = ($match_string)$/{s//title=\1/; h}" \
                      -e "/^_NET_WM_NAME\(UTF8_STRING\) = ($match_qstring)$/{s//title=\1/; h}" \
                      -e ${"'\${g; p}'"}
          } | ${coreutils}/bin/sort | ${coreutils}/bin/tr "\n" " " | \
              ${gnused}/bin/sed -r 's/^(.*) $/[\1]\n/'
        ''
      )
    ];

    xsession.windowManager.i3 = {
      enable = true;
      config = {
        assigns = { };
        bars = [ ];
        colors = with config.veritas.profiles.common.colourScheme; {
          background = "#${background}";
          # Customize our i3 colours:
          #
          # - `background` is the colour of the titlebar (only visible in tabbed or stacked mode).
          # - `border` is the colour of the border around the titlebar.
          # - `childBorder`: is the colour of the border around the whole window.
          # - `indicator` is the colour of the side that indicates where new windows will appear.
          # - `text` is the colour of the titlebar text.
          focused = {
            background = "#${background}";
            border = "#${background}";
            childBorder = "#${config.veritas.configs.i3.colourScheme.highlight}";
            indicator = "#${config.veritas.configs.i3.colourScheme.highlightBright}";
            text = "#${foreground}";
          };
          focusedInactive = cfg.colors.unfocused;
          placeholder = cfg.colors.unfocused;
          unfocused = {
            background = "#${background}";
            border = "#${background}";
            childBorder = "#${background}";
            indicator = "#${background}";
            text = "#${foreground}";
          };
          urgent = {
            background = "#${background}";
            border = "#${config.veritas.configs.i3.colourScheme.highlightBright}";
            childBorder = "#${config.veritas.configs.i3.colourScheme.highlightBright}";
            indicator = "#${background}";
            text = "#${foreground}";
          };
        };
        floating.criteria = [
          { class = "Gnome-screenshot"; }
          { class = "Peek"; }
          { class = "qjackctl"; }
          { title = "^Java iKVM Viewer.*"; }
        ];
        fonts = [ "Iosevka ${toString config.veritas.configs.i3.fontSize}" ];
        gaps = {
          inner = 2;
          outer = 2;
          smartBorders = "off";
          smartGaps = false;
        };
        keybindings = {
          # Open application selection with Win+p.
          "${modifier}+p" = "exec ${pkgs.rofi}/bin/rofi -show drun";
          # Open terminal with Win+Return.
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          # Switch workspaces with Win+{1,2,3,4,5,6,7,8,9}.
          "${modifier}+1" = "workspace ${workspaces.one}";
          "${modifier}+2" = "workspace ${workspaces.two}";
          "${modifier}+3" = "workspace ${workspaces.three}";
          "${modifier}+4" = "workspace ${workspaces.four}";
          "${modifier}+5" = "workspace ${workspaces.five}";
          "${modifier}+6" = "workspace ${workspaces.six}";
          "${modifier}+7" = "workspace ${workspaces.seven}";
          "${modifier}+8" = "workspace ${workspaces.eight}";
          "${modifier}+9" = "workspace ${workspaces.nine}";
          # Move containers between workspaces with Win+Shift+{1,2,3,4,5,6,7,8,9}.
          "${modifier}+Shift+1" = "move container to workspace ${workspaces.one}";
          "${modifier}+Shift+2" = "move container to workspace ${workspaces.two}";
          "${modifier}+Shift+3" = "move container to workspace ${workspaces.three}";
          "${modifier}+Shift+4" = "move container to workspace ${workspaces.four}";
          "${modifier}+Shift+5" = "move container to workspace ${workspaces.five}";
          "${modifier}+Shift+6" = "move container to workspace ${workspaces.six}";
          "${modifier}+Shift+7" = "move container to workspace ${workspaces.seven}";
          "${modifier}+Shift+8" = "move container to workspace ${workspaces.eight}";
          "${modifier}+Shift+9" = "move container to workspace ${workspaces.nine}";
          # Navigate using Vim bindings.
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          # Move using Vim bindings.
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          # Switch to resize mode.
          "${modifier}+r" = "mode resize";
          # Switch between layouts.
          "${modifier}+o" = "layout toggle split";
          "${modifier}+i" = "layout tabbed";
          "${modifier}+u" = "layout stacking";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+n" = "split v";
          "${modifier}+m" = "split h";
          # Exit, quit, reload and kill.
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+e" =
            "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+Shift+r" = "restart";
          # Lock the screen.
          "${modifier}+q" = "exec ${pkgs.i3lock}/bin/i3lock -c ${config.veritas.configs.xsession.wallpaperColour}";
        };
        modes = {
          resize = {
            # Leave resize mode.
            "${modifier}+r" = "mode default";
            "${modifier}+Enter" = "mode default";
            "${modifier}+Escape" = "mode default";
            # Resize bindings.
            "${modifier}+h" = "resize grow width 10 px or 10 ppt";
            "${modifier}+j" = "resize shrink height 10 px or 10 ppt";
            "${modifier}+k" = "resize grow height 10 px or 10 ppt";
            "${modifier}+l" = "resize shrink width 10 px or 10 ppt";
          };
        };
        # Use Windows key instead of ALT.
        modifier = "Mod4";
        startup = [ ];
        window = {
          titlebar = false;
          hideEdgeBorders = "none";
        };
      };
      extraConfig = with pkgs; let
        i3msg = "${config.xsession.windowManager.i3.package}/bin/i3-msg";
        defaultWorkspace = "workspace ${workspaces.one}";
      in
      ''
        # Let GNOME handle complicated stuff like monitors, bluetooth, etc.
        exec ${gnome3.gnome_settings_daemon}/libexec/gnome-settings-daemon

        # Instead of using `assigns` and `startup` to launch applications on startup, use exec with
        # i3-msg. This will avoid having *every* instance of these applications start on the assigned
        # workspace, only the initial instance.
        exec --no-startup-id ${i3msg} 'workspace ${workspaces.one}; exec ${alacritty}/bin/alacritty; ${defaultWorkspace}'
        exec --no-startup-id ${i3msg} 'workspace ${workspaces.two}; exec ${firefox-bin}/bin/firefox; exec ${ferdi}/bin/ferdi; ${defaultWorkspace}'

        # Always put the first workspace on the primary monitor.
        ${defaultWorkspace} output primary
      '' + lib.strings.optionalString config.veritas.configs.polybar.enable ''
        # Reload polybar so that it can connect to i3.
        exec --no-startup-id '${systemd}/bin/systemctl --user restart polybar'
      '';
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
