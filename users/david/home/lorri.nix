{ pkgs, config, lib, ... }:

# This file contains the configuration for lorri.

{
  services.lorri.enable = true;

  systemd.user.services.lorri."Service"."Environment" = with lib; let
    # Override default path to include `git` and `mercurial`.
    path = with pkgs; makeSearchPath "bin" [ nix gnutar gzip git mercurial ];
  in
    # Add `RUST_BACKTRACE=1` too.
    mkForce (concatStringsSep " " [ "PATH=${path}" "RUST_BACKTRACE=1" ]);
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
