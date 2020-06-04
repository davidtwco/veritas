{ config, inputs, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.common;
in
{
  options.veritas.profiles.common.enable = mkEnableOption "common configuration";

  imports = [ inputs.nixpkgs.nixosModules.notDetected ];

  config = mkIf cfg.enable {
    boot = {
      # Enable running aarch64 binaries using qemu.
      binfmt.emulatedSystems = [ "aarch64-linux" ];

      # Clean temporary directory on boot.
      cleanTmpDir = true;

      # Make memtest available as a boot option.
      loader = {
        grub.memtest86.enable = true;
        systemd-boot.memtest86.enable = true;
      };

      # Enable support for nfs and ntfs.
      supportedFilesystems = [ "cifs" "ntfs" "nfs" ];
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = "uk";
    };

    environment.systemPackages = with pkgs; [
      # Logitech Devices
      solaar
      ltunify

      # Steam Controller
      steamcontroller
    ];

    hardware.opengl = {
      driSupport32Bit = true;
      enable = true;
      extraPackages = with pkgs; [
        # VDPAU (hardware acceleration)
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
    };

    i18n.defaultLocale = "en_GB.UTF-8";

    nix = {
      autoOptimiseStore = true;
      sshServe.enable = true;
    };

    security.sudo.extraConfig = ''
      Defaults insults
    '';

    services = {
      cron.enable = true;
      dbus = {
        socketActivated = true;
        packages = with pkgs; [ gnome3.dconf ];
      };
      fwupd.enable = true;
      locate.enable = true;
      printing.enable = true;
    };

    # `nix-daemon` will hit the stack limit when using `nixFlakes`.
    systemd.services.nix-daemon.serviceConfig."LimitSTACK" = "infinity";

    time.timeZone = "Europe/London";

    veritas.configs = {
      networking.enable = true;
      yubikey.enable = true;
      user.enable = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
