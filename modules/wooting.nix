{ config, lib, pkgs, ... }:

with lib;
{
  # This module installs packages and enables configuration for machines with Wooting keyboards.
  options.veritas.hardware.wooting.enable =
    mkEnableOption "Enable support for Wooting keyboards/Wootility";

  config = mkIf config.veritas.hardware.wooting.enable {
    environment.systemPackages = with pkgs; [ wootility ];
    services.udev.packages = with pkgs; [ wooting-udev-rules ];
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
