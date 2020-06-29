{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.yubikey;
in
{
  options.veritas.configs.yubikey.enable = mkEnableOption "yubikey support";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yubikey-personalization
      yubikey-manager
    ];

    services = {
      # Required to let smart card mode of YubiKey to work.
      pcscd.enable = true;
      # Required for YubiKey devices to work.
      udev.packages = with pkgs; [ yubikey-personalization libu2f-host ];
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
