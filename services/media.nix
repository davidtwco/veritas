{ config, pkgs, lib, options, ... }:

let
  # Various configuration options for the VPN that Deluge uses - keeps the actual configuration
  # general.
  vpn = {
    # Path to the certificate for the VPN provider.
    certificate = builtins.fetchurl https://proxy.sh/proxysh.crt;
    # Names of the chains used in iptables rules.
    chains = {
      input = "${group}-vpn-input";
      output = "${group}-vpn-output";
      prerouting = "${group}-vpn-prerouting";
      postrouting = "${group}-vpn-postrouting";
    };
    # Path to the `auth-user-pass` file for OpenVPN.
    credentials = ../secrets/proxy_sh.credentials;
    # DNS servers to use for VPN traffic.
    dns = {
      ipv4 = {
        primary = "8.8.8.8";
        secondary = "8.8.4.4";
      };
      ipv6 = {
        primary = "2001:4860:4860::8888";
        secondary = "2001:4860:4860::8844";
      };
    };
    # Local network IP addresses that should be treated differently by firewall rules.
    #
    # In order to keep this configuration general and able to work on any system that it is
    # deployed to, we avoid hardcoding or detecting a netmask and instead just add rules for
    # all IETF/IANA reserved IP addresses for private networks.
    ipv4Networks = builtins.concatStringsSep "," [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
    ipv6Networks = builtins.concatStringsSep "," [ "fd00::/8" ];
    # Bit pattern to mark packets with.
    mark = "0x1";
    # Remote servers to use with OpenVPN.
    remotes = [ "eu.proxy.sh" ];
    # Arbitrary id to identify the routing table for the VPN user, needs to be consistent across
    # a handful of files.
    routeTableId = 42;
    # Names of tunnel interface for OpenVPN.
    tunnel = "tun-${group}";
    # Users whose traffic should be forced onto the VPN.
    users = [ config.services.jackett.user config.services.deluge.user ];
  };
  # Name of the group that all services run as.
  group = "media";
  # Routing script used by oneshot service and VPN up script.
  routingScript = let
    name = "${group}-vpn-routes";
    dir = pkgs.writeScriptBin name ''
      #! ${pkgs.runtimeShell} -e
      # Flush routes currently in the table.
      ${pkgs.iproute}/bin/ip route flush table ${builtins.toString vpn.routeTableId}

      # Add a rule to the routing rules for marked packets. These rules are checked in priority
      # order (lowest first - see `ip rule list`) and if no routes within match, then the next
      # rule is checked. This rule will be the second rule (the first being local packets) and
      # will apply for the marked packets.
      HAS_RULE="$(${pkgs.iproute}/bin/ip rule list | \
        ${pkgs.gnugrep}/bin/grep -c ${vpn.mark} || true)"
      if [[ $HAS_RULE == "0" ]]; then
        ${pkgs.iproute}/bin/ip rule add from all fwmark ${vpn.mark} \
          lookup ${builtins.toString vpn.routeTableId}
      fi

      HAS_VPN_INTERFACE="$(${pkgs.iproute}/bin/ip -o link show | \
        ${pkgs.gawk}/bin/awk -F': ' '{print $2}' | \
        ${pkgs.gnugrep}/bin/grep -c ${vpn.tunnel} || true)"
      if [[ $HAS_VPN_INTERFACE == "1" ]]; then
        HAS_IP="$(${pkgs.iproute}/bin/ip addr show ${vpn.tunnel} | \
          ${pkgs.gnugrep}/bin/grep -cPo '(?<= inet )([0-9\.]+)' || true)"
        if [[ $HAS_IP == "1" ]]; then
          VPN_IP="$(${pkgs.iproute}/bin/ip addr show ${vpn.tunnel} | \
            ${pkgs.gnugrep}/bin/grep -Po '(?<= inet )([0-9\.]+)')"

          ${pkgs.iproute}/bin/ip route replace default via $VPN_IP \
            table ${builtins.toString vpn.routeTableId}
        fi
      fi

      ${pkgs.iproute}/bin/ip route append default via 127.0.0.1 dev lo \
        table ${builtins.toString vpn.routeTableId}

      ${pkgs.iproute}/bin/ip route flush cache
    '';
  in "${dir}/bin/${name}";
in
  {
    # Groups {{{
    # ======
    users.groups.media.members = [ "david" ] ++ (with config.services; [
      deluge.user sabnzbd.user sonarr.user radarr.user plex.user lidarr.user
    ]);
    # }}}

    # SABnzbd {{{
    # =======
    services.sabnzbd = {
      inherit group;
      enable = true;
    };
    # }}}

    # Deluge {{{
    # =======
    services.deluge = {
      inherit group;
      enable = true;
      extraPackages = [ pkgs.unrar ];
      web = {
        enable = true;
        openFirewall = true;
      };
    };
    # }}}

    # Jackett {{{
    # =======
    services.jackett = {
      inherit group;
      enable = true;
      openFirewall = true;
      package = pkgs.unstable.jackett;
    };
    # }}}

    # Radarr {{{
    # ======
    services.radarr = {
      inherit group;
      enable = true;
      openFirewall = true;
    };
    # }}}

    # Sonarr {{{
    # ======
    services.sonarr = {
      inherit group;
      enable = true;
      openFirewall = true;
    };
    # }}}

    # Lidarr {{{
    # ======
    services.lidarr = {
      inherit group;
      enable = true;
      openFirewall = true;
      package = pkgs.unstable.lidarr;
    };
    # }}}

    # Plex {{{
    # ====
    services.plex = {
      enable = true;
      openFirewall = true;
      package = pkgs.plexPass;
    };
    # }}}

    # OpenVPN {{{
    # =======
    services.openvpn.servers = {
      "${group}" = {
        autoStart = true;
        authUserPass = {
          username = lib.removeSuffix "\n" (builtins.readFile ../secrets/proxy_sh.username);
          password = lib.removeSuffix "\n" (builtins.readFile ../secrets/proxy_sh.password);
        };
        config = ''
          # Specify the type of the layer of the VPN connection.
          dev ${vpn.tunnel}
          dev-type tun

          # Specify the underlying protocol beyond the Internet.
          proto tcp

          # The destination hostname / IP address, and port number of
          # the target VPN Server.
          ${builtins.concatStringsSep "\n" (builtins.map (r: "remote ${r} 443") vpn.remotes)}
          remote-random

          # Other parameters necessary to connect to the VPN Server.
          client
          auth-nocache
          remote-cert-tls server
          resolv-retry infinite
          nobind
          verb 4
          reneg-sec 0
          route-method exe
          route-delay 2
          comp-lzo
          tun-mtu 1500

          # The encryption and authentication algorithm.
          cipher AES-256-CBC
          auth SHA512

          # The certificate file of the destination VPN Server.
          ca ${vpn.certificate}

          # Disable the client from sending all traffic over the VPN by default.
          pull-filter ignore redirect-gateway
        '';
        up = ''
          # Workaround: OpenVPN will run `ip addr add` to assign an IP to the interface. However,
          # sometimes this won't do anything. In order to make sure that we always get an IP, sleep
          # and then run the command again.
          HAS_IP="$(${pkgs.iproute}/bin/ip addr show ${vpn.tunnel} | \
            ${pkgs.gnugrep}/bin/grep -c '$4' || true)"
          if [[ $HAS_IP == "0" ]]; then
            sleep 5
            ${pkgs.iproute}/bin/ip addr add dev ${vpn.tunnel} local $4 peer $5
          fi

          # Routing script is invoked here and at startup. When run from the OpenVPN up script, it
          # should create a new route in the VPN routing table to the newly started VPN.
          ${routingScript}
        '';
        updateResolvConf = true;
      };
    };

    networking.firewall.checkReversePath = "loose";
    networking.firewall.extraCommands = ''
      # Create the chains in the filter table.
      #
      # If we don't remove existing rules at the start of this section then there will be
      # duplicates. NixOS handles this by suggesting that rules be added to the `nixos-fw` chain.
      # However, `nixos-fw` is only referenced from `INPUT` on the `filter` table, and thus isn't
      # suitable for this (we need other tables and chains).
      #
      # Therefore, in this section, we create our own chains (and delete them if they already exist)
      # and insert a jump to them from the regular chains on all relevant tables.
      #
      # Invariant: These chains should all fall-through by default so that the regular NixOS
      # chains and rules can apply.
      for table in filter nat mangle; do
        # Delete any existing jumps to the VPN chains.
        ip46tables -t "$table" -D INPUT -j ${vpn.chains.input} 2> /dev/null || true
        ip46tables -t "$table" -D OUTPUT -j ${vpn.chains.output} 2> /dev/null || true

        for chain in ${vpn.chains.input} ${vpn.chains.output}; do
          # Flush the chain (ignoring errors if it doesn't exist).
          ip46tables -t "$table" -F "$chain" 2> /dev/null || true
          # Delete the chain (ignoring errors if it doesn't exist).
          ip46tables -t "$table" -X "$chain" 2> /dev/null || true
          # Create the chain.
          ip46tables -t "$table" -N "$chain"
        done

        # Add a jump to the VPN chains.
        ip46tables -t "$table" -A INPUT -j ${vpn.chains.input}
        ip46tables -t "$table" -A OUTPUT -j ${vpn.chains.output}
      done

      # Manually handle the prerouting/postrouting chain in the nat table - it doesn't fit the
      # above loop.
      ip46tables -t nat -D PREROUTING -j ${vpn.chains.prerouting} 2> /dev/null || true
      ip46tables -t nat -D POSTROUTING -j ${vpn.chains.postrouting} 2> /dev/null || true
      for chain in ${vpn.chains.prerouting} ${vpn.chains.postrouting}; do
        ip46tables -t nat -F "$chain" 2> /dev/null || true
        ip46tables -t nat -X "$chain" 2> /dev/null || true
        ip46tables -t nat -N "$chain"
      done
      ip46tables -t nat -A PREROUTING -j ${vpn.chains.prerouting}
      ip46tables -t nat -A POSTROUTING -j ${vpn.chains.postrouting}

      # Accept existing connections.
      ip46tables -t filter -A ${vpn.chains.input} -m conntrack --ctstate RELATED,ESTABLISHED \
        -j ACCEPT
      ip46tables -t filter -A ${vpn.chains.output} -m conntrack --ctstate RELATED,ESTABLISHED \
        -j ACCEPT

      # Copy connection mark to the packet mark.
      ip46tables -t mangle -A ${vpn.chains.output} -j CONNMARK --restore-mark

      ${
        builtins.concatStringsSep "\n" (
          builtins.map (user: ''
            # Mark all outgoing packets from the VPN user (these will be unmarked later). An
            # initial mark followed by an unmark is used because it isn't possible to check for
            # multiple destinations and negate that check (i.e. `! --dest W.X.Y.Z/F,A.B.C.D/G`
            # is disallowed) and if these checks were split up then all but one would always be
            # triggered.
            ip46tables -t mangle -A ${vpn.chains.output} ! -o lo -m owner --uid-owner ${user} \
              -j MARK --set-mark ${vpn.mark}

            # Unmark outgoing packets from the VPN user when being sent to a private network.
            # This means that hosts on the local network will still be able to browse to any web
            # services without being blocked.
            iptables -t mangle -A ${vpn.chains.output} --dest "${vpn.ipv4Networks}" \
              -m owner --uid-owner ${user} -j MARK --xor-mark ${vpn.mark}
            ip6tables -t mangle -A ${vpn.chains.output} --dest "${vpn.ipv6Networks}" \
              -m owner --uid-owner ${user} -j MARK --xor-mark ${vpn.mark}

            # Re-mark packets on the private network if they are DNS. This forces DNS to go through
            # the VPN.
            ${
              builtins.concatStringsSep "\n" (
                builtins.map ({ command, networks }: ''
                  ${command} -t mangle -A ${vpn.chains.output} --dest "${networks}" -p udp \
                    --dport domain -m owner --uid-owner ${user} -j MARK --set-mark ${vpn.mark}
                  ${command} -t mangle -A ${vpn.chains.output} --dest "${networks}" -p tcp \
                    --dport domain -m owner --uid-owner ${user} -j MARK --set-mark ${vpn.mark}
                  '') [
                    { command = "iptables"; networks = vpn.ipv4Networks; }
                    { command = "ip6tables"; networks = vpn.ipv6Networks; }
                  ]
              )
            }
          '') vpn.users
        )
      }

      # Copy packet mark to the connection mark.
      ip46tables -t mangle -A ${vpn.chains.output} -j CONNMARK --save-mark

      # Accept everything incoming on the VPN interface.
      ip46tables -t filter -A ${vpn.chains.input} -i ${vpn.tunnel} -j ACCEPT

      # Make any DNS from the VPN user go to the VPN provider's DNS.
      ${
        builtins.concatStringsSep "\n" (
          builtins.map (user: ''
            ${
              builtins.concatStringsSep "\n" (
                builtins.map ({ command, networks, dns, protocol }: ''
                  ${command} -t nat -A ${vpn.chains.output} --dest "${networks}" \
                    -p ${protocol} --dport domain -m owner --uid-owner ${user} -j DNAT \
                    --to-destination ${dns.primary}
                  ${command} -t nat -A ${vpn.chains.output} --dest "${networks}" \
                    -p ${protocol} --dport domain -m owner --uid-owner ${user} -j DNAT \
                    --to-destination ${dns.secondary}
                '') [
                  {
                    command = "iptables";
                    networks = vpn.ipv4Networks;
                    dns = vpn.dns.ipv4;
                    protocol = "tcp";
                  }
                  {
                    command = "iptables";
                    networks = vpn.ipv4Networks;
                    dns = vpn.dns.ipv4;
                    protocol = "udp";
                  }
                  {
                    command = "ip6tables";
                    networks = vpn.ipv6Networks;
                    dns = vpn.dns.ipv6;
                    protocol = "tcp";
                  }
                  {
                    command = "ip6tables";
                    networks = vpn.ipv6Networks;
                    dns = vpn.dns.ipv6;
                    protocol = "udp";
                  }
                ]
              )
            }

            # Accept all outgoing packets on `lo` and the VPN interface from the VPN user.
            ip46tables -t filter -A ${vpn.chains.output} -o lo -m owner --uid-owner ${user} \
              -j ACCEPT
            ip46tables -t filter -A ${vpn.chains.output} -o ${vpn.tunnel} -m owner \
              --uid-owner ${user} -j ACCEPT
          '') vpn.users
        )
      }

      # Masquerade all packets on the VPN interface.
      ip46tables -t nat -A ${vpn.chains.postrouting} -o ${vpn.tunnel} -j MASQUERADE
    '';

    networking.iproute2 = {
      enable = true;
      rttablesExtraConfig = ''
        ${builtins.toString vpn.routeTableId} ${group}
      '';
    };

    # Create a service that runs on system start, so that the rule to `/dev/null` all marked
    # packets always applies. The same script will be invoked when OpenVPN starts to add a new
    # route that will go through the VPN.
    systemd.services."${group}-vpn-routes" = {
      after = [ "systemd-modules-load.service" ];
      before = [ "network-pre.target" ];
      description = "Routing for ${group} VPN";
      path = [ pkgs.iproute pkgs.gnugrep pkgs.gawk ];
      reloadIfChanged = false;
      serviceConfig = {
        "Type" = "oneshot";
        "RemainAfterExit" = true;
        "ExecStart" = "${routingScript}";
      };
      unitConfig = {
        "ConditionCapability" = "CAP_NET_ADMIN";
        "DefaultDependencies" = false;
      };
      wantedBy = [ "sysinit.target" ];
      wants = [ "network-pre.target" ];
    };

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.default.rp_filter" = 2;
      "net.ipv4.conf.${vpn.tunnel}.rp_filter" = 2;
    };
    # }}}
  }

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
