{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.hushlogin;
in
{
  options.veritas.configs.hushlogin.enable = mkEnableOption "hushlogin configuration";

  config = mkIf cfg.enable {
    home.file.".hushlogin".text = ''
      # The mere presence of this file in the home directory disables the system
      # copyright notice, the date and time of the last login, the message of the
      # day as well as other information that may otherwise appear on login.
      # See `man login`.
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
