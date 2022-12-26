{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.ssh;
in
{
  options.veritas.configs.ssh.enable = mkEnableOption "ssh configuration";

  config = mkIf cfg.enable {
    home.file = {
      ".ssh/id_ecdsa_legacy.pub".source = ../data/ssh-david-legacy-id_ecdsa.pub;
      ".ssh/id_ed25519_huawei-oss.pub".source = ../data/ssh-david-huawei-oss-id_ed25519.pub;
      ".ssh/id_rsa_yubikey.pub".source = ../data/ssh-david-yubikey-id_rsa.pub;
      ".ssh/id_ecdsa_sk.pub".source = ../data/ssh-david-blink-passkey-id_ecdsa_sk.pub;
      ".ssh/id_ecdsa_iphone.pub".source = ../data/ssh-david-blink-iphone-id_ecdsa.pub;
      ".ssh/id_ecdsa_ipad.pub".source = ../data/ssh-david-blink-ipad-id_ecdsa.pub;
    };

    programs.ssh = {
      compression = true;
      enable = true;
      controlMaster = "auto";
      controlPath = "${config.home.homeDirectory}/.ssh/sockets/%r@%h-%p";
      controlPersist = "600";
      # `aes256-ctr` cipher and `hmac-sha2-256` MAC required to connect to reMarkable 2.
      extraConfig = ''
        VisualHostKey no
        StrictHostKeyChecking ask
        VerifyHostKeyDNS yes
        ForwardX11 no
        ForwardX11Trusted no
        ServerAliveCountMax 2
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-256
        KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
        HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa
      '';
      extraOptionOverrides = {
        "Include" = "${config.home.homeDirectory}/.ssh/config.local";
      };
      forwardAgent = false;
      hashKnownHosts = true;
      matchBlocks =
        let
          remoteForwards = optionals config.veritas.configs.gnupg.enable [
            {
              bind.address = "${config.home.homeDirectory}/.gnupg/socketdir/S.gpg-agent";
              host.address = "${config.home.homeDirectory}/.gnupg/socketdir/S.gpg-agent.extra";
            }
            {
              bind.address = "${config.home.homeDirectory}/.gnupg/socketdir/S.gpg-agent.ssh";
              host.address = "${config.home.homeDirectory}/.gnupg/socketdir/S.gpg-agent.ssh";
            }
          ];
        in
        {
          "github.com" = {
            extraOptions = {
              "MACs" = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
            };
            user = "git";
          };
          # In order to get GPG/SSH working on remote hosts, we need to `RemoteForward` the sockets
          # used by GPG/SSH.
          #
          # Invariant: On Linux hosts, `~/.gnupg/socketdir` is symlinked to `/run/user/<uid>/gnupg`
          # where the sockets are expected to live. On Windows, `~/.gnupg/socketdir` is symlinked to
          # `/mnt/c/wsl-pageant`. This means that on the local side, there will always be a
          # `S.gpg-agent.extra` and a `S.gpg-agent.ssh`.
          #
          # Add `StreamLocalBindUnlink` to `sshd_config` on remote hosts so that dead sockets are
          # cleaned up.
          "dtw-campaglia" = {
            inherit remoteForwards;
            forwardAgent = true;
            hostname = "campaglia.dtw.io";
            localForwards = [
              { bind.port = 8112; host = { address = "127.0.0.1"; port = 8112; }; }
              { bind.port = 8686; host = { address = "127.0.0.1"; port = 8686; }; }
              { bind.port = 8989; host = { address = "127.0.0.1"; port = 8989; }; }
              { bind.port = 7878; host = { address = "127.0.0.1"; port = 7878; }; }
              { bind.port = 8080; host = { address = "127.0.0.1"; port = 8080; }; }
              { bind.port = 9090; host = { address = "127.0.0.1"; port = 9090; }; }
              { bind.port = 9117; host = { address = "127.0.0.1"; port = 9117; }; }
              { bind.port = 32400; host = { address = "127.0.0.1"; port = 32400; }; }
            ];
            user = "david";
          };
        };
      serverAliveInterval = 300;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
