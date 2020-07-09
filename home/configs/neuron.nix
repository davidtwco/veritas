{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.neuron;
in
{
  options.veritas.configs.neuron = {
    enable = mkEnableOption ''
      Neuron package, systemd unit. Disable on new hosts so that cachix build caches can be
      configured and building Neuron can be skipped in the initial rebuild.
    '';

    directory = mkOption {
      type = types.str;
      default = "/etc/nixos/zettelkasten";
      description = ''
        Path to Zettelkasten for Neovim plugin and systemd unit. Defaults to
        `/etc/nixos/zettelkasten` which is the expected directory of the NixOS configuration (and
        thus this repository).
      '';
    };
  };

  # Neovim configuration for Neuron is in the `neovim/default.nix` file - adding to
  # `.configure.packages.veritas.start` didn't appear to work from another module.
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ neuron-zettelkasten ];

    systemd.user.services.neuron = {
      "Unit"."Description" = "Neuron Zettelkasten service";
      "Install"."WantedBy" = [ "graphical-session.target" ];
      "Service"."ExecStart" = "${pkgs.neuron-zettelkasten}/bin/neuron -d ${cfg.directory} rib -wS";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
