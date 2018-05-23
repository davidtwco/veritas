{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set up wireless networking.
  networking.hostName = "dtw-sb2";
  networking.wireless.enable = true;
}
