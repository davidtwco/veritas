{ config, pkgs, ... }:

{
  # Firewall {{{
  # ========
  networking.firewall = {
    allowPing = true;
    enable = true;
    pingLimit = "--limit 1/minute --limit-burst 5";
  };
  # }}}

  # Networkd {{{
  # ========
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;

    networks = {
      # Don't manage the interfaces created by Docker, libvirt or OpenVPN.
      "10-docker".extraConfig = ''
        [Match]
        Name=docker*

        [Link]
        Unmanaged=yes
      '';
      "11-virbr".extraConfig = ''
        [Match]
        Name=virbr*

        [Link]
        Unmanaged=yes
      '';
      "12-openvpn-tunnels".extraConfig = ''
        [Match]
        Name=tun*

        [Link]
        Unmanaged=yes
      '';
    };
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
