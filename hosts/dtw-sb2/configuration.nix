{ config, lib, pkgs, ... }:

# Need to run
#   sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable
# for this import to work correctly.
let
  unstable = import <unstable> {};
  surface_firmware = import ./firmware-surfacebook2-13in.nix;
  surface_patches = import ./patches-surface.nix;
in {
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set up wireless networking.
  networking.hostName = "dtw-sb2";
  networking.wireless.enable = true;

  # Patch the kernel.
  boot.kernelPackages = unstable.linuxPackages_4_16;
  boot.kernelPatches = [
    surface_patches.acpica
    surface_patches.cameras
    surface_patches.config
    surface_patches.ipts
    surface_patches.keyboards_and_covers
    surface_patches.sdcard_reader
    surface_patches.surfaceacpi
    surface_patches.surfacedock
    surface_patches.wifi
  ];

  # Enable all the required kernel modules.
  boot.kernelModules = [
    "hid" "hid_sensor_hub" "i2c_hid" "hid_generic" "usbhid"
    "hid_multitouch" "intel_ipts" "kvm-intel"
  ];
  boot.initrd.kernelModules = [ "hid-multitouch" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];

  # Add extra firmware.
  hardware.firmware = [ surface_firmware ];

  # Install `libwacom` for the touchscreen.
  environment.systemPackages = with pkgs; [ libwacom ];

  # Add udev rules for attaching/detaching the keyboard.
  services.udev.extraRules = "${surface_patches.repo}/root/etc/udev/rules.d/*.rules";

  # Configure hibernation.
  services.logind.lidSwitch = "hibernate";
  environment.etc."systemd/sleep.conf".text = ''
    [Sleep]
    SuspendState=freeze
  '';

  # Configure pulseaudio for the speakers.
  hardware.pulseaudio.daemon.config = {
    resample-method = "speex-float-3";
    flat-volumes = "no";
    default-sample-format = "s24le";
    default-sample-rate = "44100";
  };

  # Set up video devices.
  services.xserver.wacom.enable = true;
  services.xserver.videoDrivers = [ "intel" "nouveau" ];
  services.xserver.deviceSection = ''
    Option "TripleBuffer" "true"
    Option "TearFree" "true"
    Option "DRI" "true"
  '';

  # Set up powersaving wifi.
  networking.networkmanager.wifi.powersave = true;
  # }}}
}
