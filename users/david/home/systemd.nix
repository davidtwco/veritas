{ config, pkgs, lib, ... }:

# This file contains the configuration for systemd unit services - incl. workman, lorri and
# failed unit email notifications.

let
  cfg = config.veritas.david;
in {
  systemd.user = with lib; mkIf (!cfg.dotfiles.isWsl) {
    services = let
      # Define a service for each workman directory to update.
      workmanServices = mapAttrs' (name: workmanConfig: nameValuePair "workman-update-${name}" {
        "Unit" = {
          "Description" = "Update working directories for ${name} using Workman";
          "OnFailure" = let
            emailNotification = "systemd-notify-${config.home.username}-with-status@%n.service";
          in toString (if cfg.email.enable then [ emailNotification ] else [ ]);
        };
        "Service" = {
          "Environment" = let
            defaultEnvironment = {
              "PATH" = makeBinPath workmanConfig.path;
              # If `SSH_AUTH_SOCK` isn't overriden then gpg-agent can interfere.
              "SSH_AUTH_SOCK" = "";
              # `GIT_SSH_COMMAND` needs to be set to a key w/out a passphrase.
              "GIT_SSH_COMMAND" = let privateKey = ../../../secrets/workman_ssh.priv_key; in
                "${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=no -i ${privateKey}";
            };
            environment = defaultEnvironment // workmanConfig.environment;
          in concatStringsSep " " (mapAttrsToList (k: v: ''${k}="${v}"'') environment);
          "ExecStart" = "${pkgs.bash}/bin/bash -c '${pkgs.workman}/bin/workman update'";
          "RemainAfterExit" = true;
          "Type" = "oneshot";
          "WorkingDirectory" = workmanConfig.directory;
        };
      }) cfg.workman;
      defaultServices = {
        # Define a service for the lorri daemon.
        lorri = {
          "Unit" = {
            "Description" = "Lorri build daemon";
            "Documentation" = "https://github.com/target/lorri";
            "ConditionUser" = "!@system";
            "Requires" = "lorri.socket";
            "After" = "lorri.socket";
            "RefuseManualStart" = true;
          };
          "Service" = {
            "ExecStart" = "${pkgs.lorri}/bin/lorri daemon";
            "PrivateTmp" = true;
            "ProtectSystem" = "strict";
            "WorkingDirectory" = "%h";
            "Restart" = "on-failure";
            "Environment" = let
              path = with pkgs; makeSearchPath "bin" [ nix gnutar git mercurial ];
            in concatStringsSep " " [ "PATH=${path}" "RUST_BACKTRACE=1" ];
          };
        };
      } // (if cfg.email.enable then {
        # Define a service for sending email when units fail.
        "systemd-notify-${config.home.username}-with-status@" = {
          "Unit"."Description" = "Send a status email for %i to ${config.home.username}";
          "Service" = {
            "Type" = "oneshot";
            "RemainAfterExit" = false;
            "ExecStart" = let
              script = let
                name = "systemd-email";
                dir = pkgs.writeScriptBin name ''
                  #! ${pkgs.runtimeShell} -e
                  ${pkgs.msmtp}/bin/msmtp ${cfg.email.address} <<ERRMAIL
                  To: $1
                  From: systemd on ${cfg.hostName} <no-reply@${cfg.domain}>
                  Subject: $2
                  Content-Transfer-Encoding: 8bit
                  Content-Type: text/plain; charset=UTF-8
                  $(${pkgs.systemd}/bin/systemctl status --user --full "$2")
                  ERRMAIL
                '';
              in "${dir}/bin/${name}";
            in "${script} ${cfg.email.address} %i";
          };
        };
      } else {});
    in defaultServices // workmanServices;
    # Define a timer for each workman directory to update.
    timers = mapAttrs' (name: workmanConfig: nameValuePair "workman-update-${name}" {
      "Unit" = {};
      "Timer"."OnCalendar" = workmanConfig.schedule;
    }) cfg.workman;
    # Define a socket to activate lorri with.
    sockets.lorri = {
      "Unit"."Description" = "Socket for lorri build daemon";
      "Socket"."ListenStream" = "%t/lorri/daemon.socket";
      "Install"."WantedBy" = [ "sockets.target" ];
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
