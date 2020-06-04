{ config, lib, pkgs, ... }:

with pkgs;
with lib;
let
  cfg = config.veritas.configs.xsession;

  nvidiaOptions =
    builtins.concatStringsSep ", " (mapAttrsToList (k: v: "${k}=${v}") cfg.nvidiaSettings);
  currentMetaMode = ''
    $(${xorg.xrandr}/bin/xrandr | ${gnused}/bin/sed -nr '/(\S+) connected (primary )?[0-9]+x[0-9]+(\+\S+).*/{ s//\1: nvidia-auto-select \3 { ${nvidiaOptions} }, /; H }; ''${ g; s/\n//g; s/, $//; p }')
  '';
in
{
  options.veritas.configs.xsession = {
    enable = mkEnableOption "xsession configuration";

    nvidiaSettings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Meta-mode settings to enable using `nvidia-settings`.";
    };

    wallpaperColour = mkOption {
      default = "121212";
      description = "Define the colour for the solid colour wallpaper.";
      example = "FFFFFF";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      initExtra = with lib; with pkgs; ''
        ${hsetroot}/bin/hsetroot -solid "#${cfg.wallpaperColour}"
      '' + optionalString (cfg.nvidiaSettings != { }) ''
        # Set settings using `nvidia-settings`.
        nvidia-settings --assign CurrentMetaMode="${currentMetaMode}"
      '';
      pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ-AA";
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
