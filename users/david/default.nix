{ config, pkgs, lib, ... }:

# This file contains a NixOS module for creating my user account and dotfiles.

let
  cfg = config.veritas.david;
in {
  options.veritas.david = import ./options.nix { inherit config; inherit lib; };

  config = {
    home-manager.users.david = { config, pkgs, lib, ... }: {
      # Import the main configuration.
      imports = [ ./home ];

      # Add the `veritas.david` configuration options that are set in NixOS.
      options.veritas.david = import ./options.nix { inherit config; inherit lib; };
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

    system.activationScripts.loginctl-enable-linger-david = pkgs.lib.stringAfter [ "users" ] ''
      ${pkgs.systemd}/bin/loginctl enable-linger ${config.users.users.david.name}
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
