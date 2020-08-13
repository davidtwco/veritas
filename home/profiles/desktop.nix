{ config, lib, options, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.desktop;
in
{
  options.veritas.profiles.desktop = {
    enable = mkEnableOption "desktop configurations";

    uiScale = mkOption {
      type = types.float;
      default = 1.0;
      description = "Fraction to scale font sizes by.";
    };
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      # Multiple-service messaging client.
      ferdi
      # Mozilla Firefox is a free and open-source web browser.
      firefox-bin
      # Remmina is a remote desktop client written in GTK+.
      remmina
      # Create simple animated gifs.
      peek
      # XSel is a command-line program for getting and setting the contents of the X selection.
      xsel
      # Scrot is a minimalist command line screen capturing application.
      scrot
      # Simple volume control tool for the PulseAudio sound server.
      pavucontrol
      # Simple configuration dialog for the PulseAudio sound server.
      paprefs
      # Provides an interface to X selections ("the clipboard") from the command line.
      xclip
      # Monitor temperatures.
      psensor
      # Voice chat
      mumble
      # Password manager.
      keepassxc
      # Keybase
      keybase-gui
      # Citation manager
      zotero
      # Fonts
      meslo-lg
      source-code-pro
      source-sans-pro
      source-serif-pro
      font-awesome_5
      inconsolata
      siji
      material-icons
      powerline-fonts
      roboto
      roboto-mono
      roboto-slab
      iosevka
      iosevka-term
      iosevka-fixed
      iosevka-aile
    ] ++ (import ../../nix/fonts.nix { inherit pkgs; });

    # Enable anything used on non-headless machines that is disabled by default.
    veritas.configs = {
      alacritty.enable = true;
      autorandr.enable = true;
      gnupg.pinentry = "${pkgs.pinentry_gnome}/bin/pinentry-gnome3";
      gtk.enable = true;
      i3 = {
        enable = true;
        fontSize = options.veritas.configs.i3.fontSize.default * cfg.uiScale;
      };
      kbfs.enable = true;
      picom.enable = true;
      polybar = {
        enable = true;
        fontSize = options.veritas.configs.polybar.fontSize.default * cfg.uiScale;
      };
      qt.enable = true;
      redshift.enable = true;
      rofi.enable = true;
      xresources.enable = true;
      xsession.enable = true;
    };

    xsession.pointerCursor.size =
      let
        floatToInt = x: with lib; toInt (builtins.head (splitString "." (builtins.toString (x))));
      in
      floatToInt (24 * cfg.uiScale);
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
