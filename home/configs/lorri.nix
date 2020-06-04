{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.lorri;
in
{
  options.veritas.configs.lorri.enable = mkEnableOption "lorri configuration";

  config = mkIf cfg.enable {
    services.lorri.enable = true;

    # Override default path to include `git` and `mercurial`; and set `RUST_BACKTRACE=1`.
    systemd.user.services.lorri."Service"."Environment" =
      let
        path = with pkgs; makeSearchPath "bin" [ nix gnutar gzip git mercurial ];
      in
      mkForce (concatStringsSep " " [ "PATH=${path}" "RUST_BACKTRACE=1" ]);
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
