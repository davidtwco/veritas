{ config, pkgs, ... }:

{
  programs.mosh = {
    enable = true;
    withUtempter = true;
  };

  services.openssh = {
    enable = true;
    forwardX11 = true;
    openFirewall = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  services.xserver.desktopManager.gnome3.extraGSettingsOverrides =
    if config.services.xserver.desktopManager.gnome3.enable
    then ''
      [org.gnome.settings-daemon.plugins.power]
      sleep-inactive-ac-type='nothing'
    ''
    else null;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
