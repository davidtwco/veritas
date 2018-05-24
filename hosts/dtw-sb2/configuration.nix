{ config, lib, pkgs, ... }:

# Need to run
#   sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable
# for this import to work correctly.
let
  unstable = import <unstable> {};
in {
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set up wireless networking.
  networking.hostName = "dtw-sb2";
  networking.wireless.enable = true;

  # Patch kernel for Surface Book 2.
  boot.kernelPackages = unstable.linuxPackages_4_16;
}
