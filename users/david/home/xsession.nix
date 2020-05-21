{ config, pkgs, lib, ... }:

# This file contains the configuration for the Xsession.
let
  cfg = config.veritas.david;
in
{
  xsession = {
    enable = !cfg.dotfiles.headless;
    initExtra = with lib; with pkgs; ''
      # Load the monitor configuration.
      ${autorandr}/bin/autorandr --load veritas

      # Set wallpaper.
      ${hsetroot}/bin/hsetroot -solid "#${cfg.colourScheme.xsession.wallpaper}"
    '' + optionalString (cfg.dotfiles.nvidiaSettings != { }) (
      with pkgs;
      let
        currentMetaMode = ''
          $(${xorg.xrandr}/bin/xrandr | ${gnused}/bin/sed -nr '/(\S+) connected (primary )?[0-9]+x[0-9]+(\+\S+).*/{ s//\1: nvidia-auto-select \3 { ${options} }, /; H }; ''${ g; s/\n//g; s/, $//; p }')
        '';
        options =
          builtins.concatStringsSep ", "
            (mapAttrsToList (k: v: "${k}=${v}") cfg.dotfiles.nvidiaSettings);
      in
      ''
        # Set settings using `nvidia-settings`.
        nvidia-settings --assign CurrentMetaMode="${currentMetaMode}"
      ''
    );
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ-AA";
      size =
        let
          floatToInt = x: with lib; toInt (builtins.head (splitString "." (builtins.toString (x))));
        in
        floatToInt (24 * cfg.dotfiles.uiScale);
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
