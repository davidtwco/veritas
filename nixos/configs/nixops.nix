{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.nixops;
in
{
  options.veritas.configs.nixops.enable = mkEnableOption "nixops development support";

  config = mkIf cfg.enable {
    services = {
      # Run dnsmasq on another interface so as not to interfere with `systemd-resolved`.
      dnsmasq = {
        # Need to `mkForce` to override the options set by `services.nixops-dns`.
        extraConfig = lib.mkForce ''
          bind-interfaces
          listen-address=127.0.0.2
        '';
        resolveLocalQueries = lib.mkForce false;
      };

      # Run a DNS server that dynamically maps `<hostname>.nixops` to running NixOps
      # machines.
      nixops-dns = {
        dnsmasq = true;
        domain = "nixops";
        enable = true;
      };
    };

    # Add dnsmasq's listen address as a nameserver.
    networking.nameservers = [ "127.0.0.2" ];
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
