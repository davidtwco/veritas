{ config, lib, pkgs, ... }:

with pkgs;
with lib;
let
  cfg = config.veritas.services.workman;

  mkWorkmanService = name: workmanConfig:
    nameValuePair "workman-update-${name}" {
      "Unit" = {
        "Description" = "Update working directories for ${name} using Workman";
        "OnFailure" = workmanConfig.onFailure;
      };
      "Service" = {
        "Environment" =
          let
            defaultEnvironment = {
              "PATH" = makeBinPath workmanConfig.path;
              # If `SSH_AUTH_SOCK` isn't overriden then gpg-agent can interfere.
              "SSH_AUTH_SOCK" = "";
              # `GIT_SSH_COMMAND` needs to be set to a key w/out a passphrase.
              "GIT_SSH_COMMAND" =
                "${openssh}/bin/ssh -o StrictHostKeyChecking=no -i ${workmanConfig.privateKey}";
            };
            environment = defaultEnvironment // workmanConfig.environment;
          in
          concatStringsSep " " (mapAttrsToList (k: v: ''${k}="${v}"'') environment);
        "ExecStart" = "${nix}/bin/nix-shell --run '${workman}/bin/workman update'";
        "RemainAfterExit" = false;
        "Type" = "oneshot";
        "WorkingDirectory" = workmanConfig.directory;
      };
    };
  mkWorkmanTimer = name: workmanConfig:
    nameValuePair "workman-update-${name}" {
      "Unit" = { };
      "Timer"."OnCalendar" = workmanConfig.schedule;
    };
in
{
  options.veritas.services.workman = {
    enable = mkEnableOption "Workman working directory management";

    projects = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            directory = mkOption {
              type = types.str;
              description = "Root directory where `.workman_config` exists.";
            };

            environment = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Environment variables to set.";
            };

            onFailure = mkOption {
              type = types.str;
              default = "";
              description = "Systemd unit to be executed on failure.";
            };

            path = mkOption {
              type = types.listOf types.package;
              default = [ ];
              description = "Packages to add to path.";
            };

            privateKey = mkOption {
              type = types.path;
              description = "Private key to use for SSH authentication.";
            };

            schedule = mkOption {
              type = types.str;
              description = "Time/date to start the workman update, in `systemd.time(7)` format.";
              example = "*-*-* 2:00:00";
            };
          };
        }
      );
      default = { };
      description = "Project directories to be automatically updated using Workman";
    };
  };

  config = mkIf cfg.enable {
    systemd.user = {
      services = mapAttrs' mkWorkmanService cfg.projects;
      timers = mapAttrs' mkWorkmanTimer cfg.projects;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
