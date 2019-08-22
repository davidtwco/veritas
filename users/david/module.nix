{ lib, ... }:

# This file contains the definition for the `veritas.david` configuration options. These options
# are used in customizing dotfiles for each machine.

with lib;
{
  email = mkOption {
    type = types.str;
    default = "david@davidtw.co";
    description = "Email used in configuration files, such as `.gitconfig`.";
  };

  name = mkOption {
    type = types.str;
    default = "David Wood";
    description = "Name used in configuration files, such as `.gitconfig`.";
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
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
