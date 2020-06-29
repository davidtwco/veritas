{ config, lib, pkgs, ... }:

# This profile installs Plex; Deluge and SABnzbd; Jackett, Radarr, Sonarr and Lidarr; and a VPN.

with lib;
let
  cfg = config.veritas.profiles.media-server;
  group = "media";
in
{
  options.veritas.profiles.media-server.enable = mkEnableOption "media server configuration";

  config = mkIf cfg.enable {
    services.deluge = {
      inherit group;
      enable = true;
      extraPackages = [ pkgs.unrar ];
      web = {
        enable = true;
        openFirewall = true;
      };
    };

    services.jackett = {
      inherit group;
      enable = true;
      openFirewall = true;
      package = pkgs.jackett;
    };

    services.lidarr = {
      inherit group;
      enable = true;
      openFirewall = true;
      package = pkgs.lidarr;
    };

    services.plex = {
      enable = true;
      openFirewall = true;
      package = pkgs.plexPass;
    };

    services.sabnzbd = {
      inherit group;
      enable = true;
    };

    services.sonarr = {
      inherit group;
      enable = true;
      openFirewall = true;
    };

    services.radarr = {
      inherit group;
      enable = true;
      openFirewall = true;
    };

    veritas.services.per-user-vpn = {
      enable = true;
      servers."${group}" = {
        certificate = ../secrets/mullvad-vpn-cert;
        credentials = {
          username = ../secrets/mullvad-vpn-username;
          password = ../secrets/mullvad-vpn-password;
        };
        mark = "0x1";
        protocol = "udp";
        remotes = [
          "es-mad-002.mullvad.net 1196"
          "es-mad-001.mullvad.net 1196"
          "es-mad-003.mullvad.net 1196"
          "es-mad-005.mullvad.net 1196"
          "es-mad-004.mullvad.net 1196"
        ];
        routeTableId = 42;
        users = [ config.services.jackett.user config.services.deluge.user ];
      };
    };

    users.groups.media.members = [ config.users.users.david.name ] ++ (
      with config.services; [
        deluge.user
        sabnzbd.user
        sonarr.user
        radarr.user
        plex.user
        lidarr.user
      ]
    );
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
