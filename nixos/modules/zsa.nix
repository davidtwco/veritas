{ config, lib, pkgs, ... }:

with lib;
{
  options.hardware.zsa.enable =
    mkEnableOption "Enable support for ZSA keyboards";

  config = mkIf config.hardware.zsa.enable {
    environment.systemPackages = with pkgs; [ wally-cli wally ];
    services.udev.packages = with pkgs; [ oryx-udev-rules wally-udev-rules ];
  };
}
