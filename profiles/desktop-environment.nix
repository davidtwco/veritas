{ config, pkgs, options, lib, ... }:

# This profile installs X.org, a desktop environment and desktop packages.

with lib;
let
  cfg = config.veritas.profiles.desktop-environment;
in {
  options.veritas.profiles.desktop-environment.enable =
    mkEnableOption "Enable desktop environment configuration";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Desktop applications/utilities
      scrot xsel xlibs.xbacklight arandr pavucontrol paprefs xclip gnome3.gnome-tweaks hsetroot

      # Gnome extensions
      gnomeExtensions.appindicator gnomeExtensions.dash-to-dock gnomeExtensions.topicons-plus

      firefox jetbrains.pycharm-community remmina peek chrome-gnome-shell plotinus

      # Chat apps
      weechat mumble_git keybase-gui franz

      # Terminal emulator
      unstable.alacritty
    ];

    fonts.fonts = with pkgs; [
      meslo-lg source-code-pro source-sans-pro source-serif-pro font-awesome_5 inconsolata
      siji material-icons powerline-fonts roboto roboto-mono roboto-slab iosevka
    ];

    hardware.pulseaudio.enable = true;
    hardware.pulseaudio.support32Bit = true;
    hardware.pulseaudio.package = pkgs.pulseaudioFull;

    programs = {
      # Change light from terminal.
      light.enable = true;
      # Add Ctrl+Shift+P menus to applications.
      plotinus.enable = true;
    };

    services = {
      gnome3.chrome-gnome-shell.enable = true;
      xserver = {
        enable = true;
        desktopManager = {
          gnome3.enable = true;
          wallpaper.mode = "center";
        };
        displayManager.gdm = {
          enable = true;
          wayland = !(builtins.elem "nvidia" config.services.xserver.videoDrivers);
        };
        layout = "gb";
      };
    };

    sound.mediaKeys = {
      enable = true;
      volumeStep = "5%";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
