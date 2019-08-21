{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.david;
in {
  options.david = {
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

    dotfiles = mkOption {
      description = "Dotfiles-specific options.";
      type = types.submodule {
        options = {
          headless = mkOption {
            type = types.bool;
            default = true;
            description = "Is this a headless host without a desktop environment?";
          };
        };
      };
    };
  };

  config = {
    # Manage user account.
    users.users.david = {
      description = cfg.name;
      extraGroups = [
        "adbusers" "audio" "disk" "video" "wheel" "docker" "libvirtd" "lxd" "plugdev"
        "systemd-journal" "vboxusers"
      ];
      hashedPassword = "$6$kvMx6lEzQPhkSj8E$KfP/qM2cMz5VqNszLjeOBGnny3PdIyy0vnHzIgP.gb1XqTI/qq3nbt0Qg871pkmwJwIu3ZGt57yShMjFFMR3x1";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        (builtins.readFile ./public_keys/id_ecdsa_legacy.pub)
        (builtins.readFile ./public_keys/id_rsa_yubikey.pub)
      ];
      # `shell` attribute cannot be removed! If no value is present then there will be no shell
      # configured for the user and SSH will not allow logins!
      shell = pkgs.zsh;
      uid = 1000;
    };

    # Use home-manager to manage dotfiles.
    home-manager.users.david = (import ./home) {
      email = cfg.email;
      name = cfg.name;
      headless = cfg.dotfiles.headless;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
