{ config, lib, ... }:

# This file contains the definition for the `veritas.david` configuration options. These options
# are used in customizing dotfiles for each machine. Defaults cannot depend on any options that
# are not defined in this file (those will only exist in NixOS).

with lib;
let
  # Helper function to define an option for a colour.
  mkColour = description: default: mkOption {
    inherit default;
    description = ''
      Define the colour for ${description}. Must be a hexidecimal representation, without leading
      pound.
    '';
    example = "FFFFFF";
    type = types.str;
  };
  # Helper function to construct a colour with a foreground and background component.
  mkColourWithFgBg = description: fgHex: bgHex: {
    bg = mkColour "the background colour of ${description}" bgHex;
    fg = mkColour "the foreground colour of ${description}" fgHex;
  };
  # Short variable to access colour configuration.
  colours = config.veritas.david.colourScheme;
in
{
  # Define a colour scheme. These colours are used through the home configuration for
  # customization.
  colourScheme = {
    # Basic sixteen colour definitions for the colour scheme.
    basic = {
      # Background, foreground and cursor.
      background = mkColour "background" "1C1C1C";
      cursor = mkColour "foreground" colours.basic.foreground;
      foreground = mkColour "foreground" "C5C8C6";
      # Regular colours.
      black = mkColour "black" "282A2E";
      red = mkColour "red" "A54242";
      green = mkColour "green" "8C9440";
      yellow = mkColour "yellow" "DE935F";
      blue = mkColour "blue" "5F819D";
      magenta = mkColour "magenta" "85678F";
      cyan = mkColour "cyan" "5E8D87";
      white = mkColour "white" "707880";
      # Bright colours.
      brightBlack = mkColour "bright black" "373B41";
      brightRed = mkColour "bright red" "CC6666";
      brightGreen = mkColour "bright green" "B5BD68";
      brightYellow = mkColour "bright yellow" "F0C674";
      brightBlue = mkColour "bright blue" "81A2BE";
      brightMagenta = mkColour "bright magenta" "B294BB";
      brightCyan = mkColour "bright cyan" "8ABEB7";
      brightWhite = mkColour "bright white" "C5C8C6";
    };
    # Colours specific to Delta.
    delta = {
      minus = {
        regular = mkColour "delta's minus" "260808";
        emphasised = mkColour "delta's emphasised minus" "3f0d0d";
      };
      plus = {
        regular = mkColour "delta's plus" "0b2608";
        emphasised = mkColour "delta's emphasised plus" "123f0d";
      };
    };
    # Colours specific to Starship.
    #
    # Starship seems to mangle the colour slightly, so this hex produces the same
    # "optical" colour as the regular muted grey used throughout the configuration.
    starship.mutedGrey = mkColour "starship's muted grey" "6B6B6B";
    # Colours specific to Neovim.
    neovim = {
      termdebugProgramCounter = mkColour "termdebug's gutter breakpoint indicator"
        colours.neovim.termdebugBreakpoint.bg;
      termdebugBreakpoint = mkColourWithFgBg "termdebug's current line" "B2B2B2" "2B2B2B";
    };
    # Colours specific to the xsession.
    xsession.wallpaper = mkColour "wallpaper" "121212";
  };

  domain = mkOption {
    type = types.str;
    default = "davidtw.co";
    description = "Domain used in configuration files, such as `.gitconfig`";
  };

  dotfiles = {
    autorandrProfile = mkOption {
      type = types.attrs;
      description = "Configuration for autorandr";
    };

    headless = mkOption {
      type = types.bool;
      default = true;
      description = "Is this a headless host without a desktop environment?";
    };

    isWsl = mkOption {
      type = types.bool;
      default = false;
      description = "Is this a WSL host?";
    };

    isNonNixOS = mkOption {
      type = types.bool;
      default = config.veritas.david.dotfiles.isWsl;
      description = "Is this a non-NixOS host?";
    };

    uiScale = mkOption {
      type = types.float;
      default = 1.5;
      description = "Fraction to scale font sizes by";
    };
  };

  email = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable sending email from this host?";
    };

    address = mkOption {
      type = types.str;
      default = "david@${config.veritas.david.domain}";
      description = "Email used in configuration files, such as `.gitconfig`";
    };
  };

  hostName = mkOption {
    type = types.str;
    description = "Name of this host";
  };

  name = mkOption {
    type = types.str;
    default = "David Wood";
    description = "Name used in configuration files, such as `.gitconfig`";
  };

  workman = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          directory = mkOption {
            type = types.str;
            description = "Root directory where `.workman_config` exists";
          };

          environment = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = "Environment variables to set";
          };

          path = mkOption {
            type = types.listOf types.package;
            default = [];
            description = "Packages to add to path";
          };

          schedule = mkOption {
            type = types.str;
            description = "Time/date to start the workman update, in `systemd.time(7)` format";
            example = "*-*-* 2:00:00";
          };
        };
      }
    );
    default = {};
    description = "Project directories to be automatically updated using Workman";
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
