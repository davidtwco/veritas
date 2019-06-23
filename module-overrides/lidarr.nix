{ config, pkgs, lib, ... }:

# This file is temporary and worksaround being unable to change the `pkgs.lidarr` version to
# unstable without killing the server from memory exhaustion.

with lib;

let
  cfg = config.services.lidarr;
in
{
  options = {
    services.lidarr = {
      enable = mkEnableOption "Lidarr";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.lidarr = {
      description = "Lidarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "lidarr";
        Group = "lidarr";
        ExecStart = "${pkgs.unstable.lidarr}/bin/Lidarr";
        Restart = "on-failure";

        StateDirectory = "lidarr";
        StateDirectoryMode = "0770";
      };
    };

    users.users.lidarr = {
      uid = config.ids.uids.lidarr;
      home = "/var/lib/lidarr";
      group = "lidarr";
    };

    users.groups.lidarr.gid = config.ids.gids.lidarr;
  };
}
