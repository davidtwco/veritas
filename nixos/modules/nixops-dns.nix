{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.services.nixops-dns;
in
{
  options.veritas.services.nixops-dns = {
    enable = mkEnableOption "nixops-dns daemon";

    instances = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          domain = mkOption {
            type = types.str;
            default = "nixops";
            description = ''
              Domain name used for NixOps machines. For example, if this option is set to "dev"
              then a host named "db" would be accessible at "db.dev".
            '';
          };

          ipAddress = mkOption {
            type = types.str;
            description = ''
              IP address to run the nixops-dns instance on. Will be added to
              `networking.nameservers` and will always run on port 53.
            '';
          };
        };
      });
      default = { };
      example = literalExample ''
        {
          "david" = {
            domain = "local-dev";
            ipAddress = "127.0.0.3";
          };
        }
      '';
      description = "Instances of nixops-dns to run for different users on the system.";
    };
  };

  config = mkIf cfg.enable {
    # Run a DNS server for running NixOps machines. Don't use upstream module for this as it
    # doesn't allow changing the `--addr` parameter.
    systemd.services =
      mapAttrs'
        (user: cfg': nameValuePair "nixops-dns-${user}" {
          description = "DNS server for resolving NixOps machines from ${user} user";
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            "AmbientCapabilities" = "CAP_NET_BIND_SERVICE";
            "Type" = "simple";
            "User" = user;
            # Port must remain `53` to work with `systemd-resolved`.
            "ExecStart" = ''
              ${pkgs.nixops-dns}/bin/nixops-dns \
                --addr=${cfg'.ipAddress}:53  \
                --domain=.${cfg'.domain}
            '';
          };
        })
        cfg.instances;

    # Add nixops-dns's listen address as a nameserver.
    networking.nameservers = mapAttrsToList (_: cfg': cfg'.ipAddress) cfg.instances;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
