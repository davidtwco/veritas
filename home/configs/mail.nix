{ config, lib, pkgs, ... }:

# This file contains the configuration for mail accounts and msmtp.
with lib;
let
  cfg = config.veritas.configs.mail;

  notifyScript =
    let
      name = "systemd-email";
      dir = pkgs.writeScriptBin name ''
        #! ${pkgs.runtimeShell} -e
        ${pkgs.msmtp}/bin/msmtp ${cfg.email} <<ERRMAIL
        To: $1
        From: systemd on behalf of ${cfg.name} <${cfg.email}>
        Subject: $2
        Content-Transfer-Encoding: 8bit
        Content-Type: text/plain; charset=UTF-8
        $(${pkgs.systemd}/bin/systemctl status --user --full "$2")
        ERRMAIL
      '';
    in
    "${dir}/bin/${name}";
in
{
  options.veritas.configs.mail = {
    enable = mkEnableOption "mail configuration";

    email = mkOption {
      type = types.str;
      default = "david@davidtw.co";
      description = "Email that mail is sent from.";
    };

    name = mkOption {
      type = types.str;
      default = "David Wood";
      description = "Name that mail is sent from.";
    };

    withSystemdNotifyUnit = mkOption {
      type = types.bool;
      default = true;
      description = "Add a systemd unit for sending an email about the status of a systemd unit.";
    };
  };

  config = mkIf cfg.enable {
    accounts.email.accounts.personal = {
      address = cfg.email;
      msmtp.enable = true;
      passwordCommand = "${pkgs.coreutils}/bin/cat ${../secrets/fastmail-password}";
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
      userName = cfg.email;
    };

    home.file.".forward".text = cfg.email;

    programs.msmtp.enable = true;

    systemd.user.services."systemd-notify-${config.home.username}-with-status@" =
      mkIf cfg.withSystemdNotifyUnit {
        "Unit"."Description" = "Send a status email for %i to ${config.home.username}";
        "Service" = {
          "Type" = "oneshot";
          "RemainAfterExit" = false;
          "ExecStart" = "${notifyScript} ${cfg.email} %i";
        };
      };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
