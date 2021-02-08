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
      ".ssh/id_rsa_yubikey.pub".source = ../data/ssh-david-yubikey-id_rsa.pub;
    };

    programs.ssh = {
      compression = true;
      enable = true;
      controlMaster = "auto";
      controlPath = "${config.home.homeDirectory}/.ssh/sockets/%r@%h-%p";
      controlPersist = "600";
      extraConfig = ''
        VisualHostKey no
        StrictHostKeyChecking ask
        VerifyHostKeyDNS yes
        ForwardX11 no
        ForwardX11Trusted no
        ServerAliveCountMax 2
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
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
          remoteForwards = [
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
            identitiesOnly = true;
            identityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
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
          "dtw-avendahl" = {
            inherit remoteForwards;
            forwardAgent = true;
            hostname = "avendahl.dtw.io";
            identitiesOnly = true;
            identityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
            user = "david";
          };
          "dtw-campaglia" = {
            inherit remoteForwards;
            forwardAgent = true;
            hostname = "192.168.1.118";
            identitiesOnly = true;
            identityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
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
          "dtw-volkov" = {
            inherit remoteForwards;
            forwardAgent = true;
            hostname = "davidwoodpc.office.codeplay.com";
            identitiesOnly = true;
            identityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
            user = "david";
          };
        };
      serverAliveInterval = 300;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
