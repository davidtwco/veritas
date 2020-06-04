{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.gtk;
in
{
  options.veritas.configs.gtk.enable = mkEnableOption "gtk configuration";

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      gtk3.extraConfig."gtk-application-prefer-dark-theme" = 1;
      iconTheme = {
        package = pkgs.paper-icon-theme;
        name = "Paper";
      };
      theme = {
        package = pkgs.arc-theme;
        name = "Arc-Darker";
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
