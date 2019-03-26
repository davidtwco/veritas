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
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
