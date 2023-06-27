{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.ssh;
in
{
  options.veritas.configs.ssh.enable = mkEnableOption "ssh configuration";

  config = mkIf cfg.enable {
    home.file = {
      ".ssh/id_rsa_yubikey.pub".source = ../data/ssh-david-yubikey-id_rsa.pub;
      ".ssh/id_ed25519_1password_github.pub".source = ../data/ssh-david-1password-github-id_ed25519.pub;
      ".ssh/id_ed25519_1password_gitlab.pub".source = ../data/ssh-david-1password-gitlab-id_ed25519.pub;
      ".ssh/id_ed25519_1password_gitee.pub".source = ../data/ssh-david-1password-gitee-id_ed25519.pub;
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
      matchBlocks."github.com" = {
        extraOptions."MACs" =
          "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com";
        user = "git";
      };
      serverAliveInterval = 300;
    };
  };
}
