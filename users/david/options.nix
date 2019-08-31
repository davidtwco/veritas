{ config, lib, ... }:

# This file contains the definition for the `veritas.david` configuration options. These options
# are used in customizing dotfiles for each machine. Defaults cannot depend on any options that
# are not defined in this file (those will only exist in NixOS).

with lib;
{
  domain = mkOption {
    type = types.str;
    default = "davidtw.co";
    description = "Domain used in configuration files, such as `.gitconfig`";
  };

  dotfiles = {
    headless = mkOption {
      type = types.bool;
      default = true;
      description = "Is this a headless host without a desktop environment?";
    };

    isWsl = mkOption {
      type = types.bool;
      default = false;
      description = "Is this a WSL host?";
    };

    isNonNixOS = mkOption {
      type = types.bool;
      default = config.veritas.david.dotfiles.isWsl;
      description = "Is this a non-NixOS host?";
    };
  };

  email = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable sending email from this host?";
    };

    address = mkOption {
      type = types.str;
      default = "david@${config.veritas.david.domain}";
      description = "Email used in configuration files, such as `.gitconfig`";
    };
  };

  hostName = mkOption {
    type = types.str;
    description = "Name of this host";
  };

  name = mkOption {
    type = types.str;
    default = "David Wood";
    description = "Name used in configuration files, such as `.gitconfig`";
  };

  workman = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        directory = mkOption {
          type = types.str;
          description = "Root directory where `.workman_config` exists";
        };

        environment = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = "Environment variables to set";
        };

        path = mkOption {
          type = types.listOf types.package;
          default = [];
          description = "Packages to add to path";
        };

        schedule = mkOption {
          type = types.str;
          description = "Time/date to start the workman update, in `systemd.time(7)` format";
          example = "*-*-* 2:00:00";
        };
      };
    });
    default = {};
    description = "Project directories to be automatically updated using Workman";
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
