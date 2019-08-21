{ config, pkgs, lib, ... }:

# This file contains a NixOS module for creating my user account and dotfiles.

let
  module = import ./module.nix { inherit lib; };
  cfg = config.veritas.david;
in {
  options.veritas.david = module;

  config = {
    home-manager.users.david = { config, pkgs, ... }: {
      # Import the main configuration.
      imports = [ ./home ];

      # Add the `veritas.david` configuration options that are set in NixOS.
      options.veritas.david = module;
      config.veritas.david = cfg;
    };

    # Create user account.
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
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
