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

    nix = {
      trustedUsers = [ "david" ];

      # Use regular SSH keys for SSH-serving Nix packages.
      sshServe.keys = config.users.users.david.openssh.authorizedKeys.keys;
    };

    # Nix will hit the stack limit when using `nixFlakes`.
    security.pam.loginLimits = [
      { domain = config.users.users.david.name; item = "stack"; type = "-"; value = "unlimited"; }
    ];

    # Make `/run/user/X` larger.
    services.logind.extraConfig = ''
      RuntimeDirectorySize=20%
    '';

    # Required to use `fish` as a shell on a remote host, else no SSH.
    programs.fish.enable = true;

    users = {
      users.david = {
        description = "David Wood";
        extraGroups = [
          "adbusers"
          "adm"
          "audio"
          "disk"
          "docker"
          "ftp"
          "games"
          "http"
          "input"
          "libvirtd"
          "locate"
          "log"
          "lp"
          "lxd"
          "plugdev"
          "rfkill"
          "sys"
          "systemd-journal"
          "uucp"
          "vboxusers"
          "video"
          "wheel"
          "wireshark"
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

    # Configure nixops-dns for my user.
    veritas.services.nixops-dns.instances.david.ipAddress = "127.0.0.2";
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
