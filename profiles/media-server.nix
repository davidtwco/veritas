{ config, pkgs, options, lib, ... }:

# This profile installs Plex; Deluge and SABnzbd; Jackett, Radarr, Sonarr and Lidarr; and a VPN.

with lib;
let
  cfg = config.veritas.profiles.media-server;
  group = "media";
in
{
  options.veritas.profiles.media-server.enable = mkEnableOption "Enable media server configuration";

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
      package = pkgs.unstable.jackett;
    };

    services.lidarr = {
      inherit group;
      enable = true;
      openFirewall = true;
      package = pkgs.unstable.lidarr;
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
        certificate = builtins.fetchurl https://proxy.sh/proxysh.crt;
        credentials = {
          username = ../secrets/proxy_sh.username;
          password = ../secrets/proxy_sh.password;
        };
        mark = "0x1";
        remotes = [ "eu.proxy.sh" ];
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

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
