{ config, pkgs, lib, ... }:

# This file contains the configuration for mail accounts and msmtp.
let
  cfg = config.veritas.david;
in
{
  accounts.email.accounts = lib.mkIf cfg.email.enable {
    personal = {
      address = cfg.email.address;
      msmtp.enable = true;
      passwordCommand = "${pkgs.coreutils}/bin/cat ${../../../secrets/mail.password}";
      primary = true;
      realName = cfg.name;
      smtp = {
        host = "smtp.fastmail.com";
        port = 465;
        tls = {
          enable = true;
          useStartTls = false;
        };
      };
      userName = cfg.email.address;
    };
  };

  home.file.".forward".text = cfg.email.address;

  programs.msmtp.enable = cfg.email.enable;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
