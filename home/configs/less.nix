{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.less;
in
{
  options.veritas.configs.less.enable = mkEnableOption "less configuration";

  config = mkIf cfg.enable {
    # Allow scrolling left and right with `h` and `l` in `less`.
    home.file.".lesskey".text = ''
      h left-scroll
      l right-scroll
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
