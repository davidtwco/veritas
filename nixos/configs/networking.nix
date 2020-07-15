{ config, lib, options, ... }:

with lib;
let
  cfg = config.veritas.configs.networking;
in
{
  options.veritas.configs.networking.enable = mkEnableOption "networking configuration";

  config = mkIf cfg.enable {
    networking = {
      firewall = {
        allowPing = true;
        enable = true;
        pingLimit = "--limit 1/minute --limit-burst 5";
      };

      networkmanager.enable = false;

      timeServers = options.networking.timeServers.default ++ [
        "0.uk.pool.ntp.org"
        "1.uk.pool.ntp.org"
        "2.uk.pool.ntp.org"
        "3.uk.pool.ntp.org"
      ];

      useDHCP = false;
      useNetworkd = true;
    };

    services = {
      openssh = {
        enable = true;
        extraConfig = ''
          # Required for GPG forwarding.
          StreamLocalBindUnlink yes

          Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
          MACs hmac-sha2-512-etm@openssh.com
          KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
          RekeyLimit 256M
        '';
        forwardX11 = true;
        openFirewall = true;
        passwordAuthentication = false;
        permitRootLogin = "no";
      };

      # Fallback to Cloudflare DNS instead of Google.
      resolved.fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };

    systemd.network = {
      enable = true;
      networks = {
        # Don't manage the interfaces created by OpenVPN.
        "20-tunnel-interfaces".extraConfig = ''
          [Match]
          Name=tun*

          [Link]
          Unmanaged=yes
        '';
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
