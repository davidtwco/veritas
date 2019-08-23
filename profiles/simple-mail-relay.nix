{ config, pkgs, options, lib, ... }:

# This profile installs a simple mail server.

with lib;
let
  cfg = config.veritas.profiles.simple-mail-relay;
in {
  options.veritas.profiles.simple-mail-relay = {
    enable = mkEnableOption "Enable simple mail relay configuration";

    domain = mkOption {
      default = config.veritas.david.domain;
      description = "Domain that emails are sent from";
      type = types.str;
    };

    email = mkOption {
      default = config.veritas.david.email;
      description = "Email";
      type = types.str;
    };

    host = mkOption {
      default = "smtp.fastmail.com";
      description = "Hostname of upstream mail server";
      type = types.str;
    };

    password = mkOption {
      default = ../secrets/mail.password;
      description = "Path to a file that contains the upstream mail server password";
      type = types.path;
    };

    port = mkOption {
      default = 465;
      description = "Port of upstream mail server";
      type = types.port;
    };

    username = mkOption {
      default = cfg.email;
      description = "Username for the upstream mail server";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ mailutils ];

    networking.defaultMailServer = {
      authUser = "${cfg.username}";
      authPassFile = "${cfg.password}";
      directDelivery = true;
      domain = "${cfg.domain}";
      hostName = "${cfg.host}:${builtins.toString cfg.port}";
      root = "${cfg.email}";
      setSendmail = true;
      useSTARTTLS = false;
      useTLS = true;
    };

    systemd.services."systemd-unit-status-email@" = let
      systemdEmailScript = let
        name = "systemd-email";
        dir = pkgs.writeScriptBin name ''
          #! ${pkgs.runtimeShell} -e
          ${pkgs.system-sendmail}/bin/sendmail -t <<ERRMAIL
          To: $1
          From: systemd on ${config.networking.hostName} <no-reply@${cfg.domain}>
          Subject: $2
          Content-Transfer-Encoding: 8bit
          Content-Type: text/plain; charset=UTF-8

          $(${pkgs.systemd}/bin/systemctl status --full "$2")
          ERRMAIL
        '';
      in "${dir}/bin/${name}";
    in {
      description = "Send a status email for %i";
      enable = true;
      reloadIfChanged = false;
      serviceConfig = {
        "Type" = "oneshot";
        "RemainAfterExit" = false;
        "ExecStart" = "${systemdEmailScript} ${cfg.email} %i";
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
