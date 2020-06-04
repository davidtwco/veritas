{ config, inputs, lib, name, pkgs, ... }:

with pkgs;
with lib;
let
  cfg = config.veritas.configs.user;
in
{
  options.veritas.configs.user.enable = mkEnableOption "user account";

  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = mkIf cfg.enable {
    home-manager = mkIf (hasAttr name inputs.self.internal.homeManagerConfigurations) {
      useUserPackages = true;
      useGlobalPkgs = true;
      users.david = inputs.self.internal.homeManagerConfigurations."${name}";
    };

    # Use regular SSH keys for SSH-serving Nix packages.
    nix.sshServe.keys = config.users.users.david.openssh.authorizedKeys.keys;

    services = {
      # Make `/run/user/X` larger.
      logind.extraConfig = ''
        RuntimeDirectorySize=20%
      '';

      # Run NixOps DNS as the user which runs NixOps.
      nixops-dns.user = config.users.users.david.name;
    };

    # Enable user units to persist after sessions end.
    system.activationScripts.loginctl-enable-linger-david = lib.stringAfter [ "users" ] ''
      ${systemd}/bin/loginctl enable-linger ${config.users.users.david.name}
    '';

    # Required to use `fish` as a shell on a remote host, else no SSH.
    programs.fish.enable = true;

    users = {
      users.david = {
        description = "David Wood";
        extraGroups = [
          "adbusers"
          "audio"
          "disk"
          "docker"
          "input"
          "libvirtd"
          "lxd"
          "plugdev"
          "systemd-journal"
          "vboxusers"
          "video"
          "wheel"
        ];
        hashedPassword = "$6$kvMx6lEzQPhkSj8E$KfP/qM2cMz5VqNszLjeOBGnny3PdIyy0vnHzIgP.gb1XqTI/qq3nbt0Qg871pkmwJwIu3ZGt57yShMjFFMR3x1";
        isNormalUser = true;
        openssh.authorizedKeys.keyFiles = [
          ../data/ssh-david-legacy-id_ecdsa.pub
          ../data/ssh-david-yubikey-id_rsa.pub
        ];
        # `shell` attribute cannot be removed! If no value is present then there will be no shell
        # configured for the user and SSH will not allow logins!
        shell = fish;
        uid = 1000;
      };

      # Do not allow users to be added or modified except through Nix configuration.
      mutableUsers = false;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
