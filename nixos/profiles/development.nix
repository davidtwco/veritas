{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.development;
in
{
  options.veritas.profiles.development.enable = mkEnableOption "development configuration";

  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/share/fish" "/share" ];

    hardware.opengl.extraPackages = with pkgs; [
      # OpenCL
      intel-openclrt
      intel-compute-runtime
    ];

    programs = {
      adb.enable = true;

      ccache.enable = true;

      bcc.enable = true;

      mosh = {
        enable = true;
        withUtempter = true;
      };

      nano.syntaxHighlight = true;

      wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
    };

    veritas.configs = {
      virtualisation.enable = true;
      nixops.enable = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
