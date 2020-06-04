{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.desktop;
in
{
  options.veritas.profiles.desktop.enable = mkEnableOption "desktop configuration";

  config = mkIf cfg.enable {
    hardware.pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
    };

    services = {
      gnome3 = {
        core-os-services.enable = true;
        core-utilities.enable = true;
      };

      keybase.enable = true;

      xserver = {
        enable = true;
        exportConfiguration = true;
        # i3 is the primary desktop but without GNOME being enabled, gdm doesn't have any session
        # files and crashes as a result.
        desktopManager.gnome3.enable = true;
        displayManager.gdm = {
          enable = true;
          # Need to upgrade to Sway to use Wayland.
          wayland = false;
          nvidiaWayland = true;
        };
        layout = "gb";
      };
    };

    sound.mediaKeys = {
      enable = true;
      volumeStep = "5%";
    };

    veritas.configs.virtualisation.virtualbox.headless = false;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
