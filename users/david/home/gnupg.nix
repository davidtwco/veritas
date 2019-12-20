{ config, pkgs, lib, ... }:

# This file contains the configuration for GnuPG.

with lib;
{
  programs.gpg = {
    enable = true;
    settings = {
      # Set default key.
      "default-key" = config.programs.git.signing.key;
      # Disable inclusion of the version string in ASCII armored output.
      "no-emit-version" = true;
      # Use armoured output.
      "armor" = true;
      # Disable comment string in clear text signatures and ASCII armored messages.
      "no-comments" = true;
      # Display long key IDs.
      "keyid-format" = "0xlong";
      # List all keys (or the specified ones) along with their fingerprints.
      "with-fingerprint" = true;
      # Display the calculated validity of user IDs during key listings.
      "list-options" = "show-uid-validity";
      "verify-options" = "show-uid-validity";
      # Try to use the GnuPG-Agent. With this option, GnuPG first tries to connect to the agent
      # before it asks for a passphrase.
      "use-agent" = true;
      # Use unicode.
      "charset" = "utf-8";
      # Cross-certify subkeys are present and valid.
      "require-cross-certification" = true;
      # Disable caching of passphrase for symmetrical operations.
      "no-symkey-cache" = true;
      # Disable putting recipient key IDs into messages.
      "throw-keyids" = true;
      # This is the server that --recv-keys, --send-keys, and --search-keys will communicate with
      # to receive keys from, send keys to, and search for keys on.
      "keyserver" = "hkps://hkps.pool.sks-keyservers.net";
      # no-honor-keyserver-url: When using --refresh-keys, if the key in question has a preferred
      #                         keyserver URL, then disable use of that preferred keyserver to
      #                         refresh the key from.
      # include-revoked: When searching for a key with --search-keys, include keys that are marked
      #                  on the keyserver as revoked.
      "keyserver-options" = "no-honor-keyserver-url include-revoked";
      # List of personal digest preferences. When multiple digests are supported by all recipients,
      # choose the strongest one.
      "personal-cipher-preferences" = "AES256 AES192 AES";
      # List of personal digest preferences. When multiple ciphers are supported by all recipients,
      # choose the strongest one.
      "personal-digest-preferences" = "SHA512 SHA384 SHA256";
      # Use ZLIB, BZIP2, ZIP, or no compression.
      "personal-compress-preferences" = "ZLIB BZIP2 ZIP Uncompressed";
      # Message digest algorithm used when signing a key.
      "cert-digest-algo" = "SHA512";
      # SHA512 as digest for symmetric operations.
      "s2k-digest-algo" = "SHA512";
      # AES256 as cipher for symmetric operations.
      "s2k-cipher-algo" = "AES256";
      # This preference list is used for new keys and becomes the default for "setpref" in the edit
      # menu.
      "default-preference-list" =
        "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
    };
  };

  services.gpg-agent = let
    # Enable logging to a socket for debugging.
    # `watchgnupg --time-only --force ${config.home.homeDirectory}/.gnupg/S.log`
    enableLogging = false;
    pinentry =
      "${pkgs.pinentry_gnome}/bin/"
      + (if config.veritas.david.dotfiles.headless then "pinentry-tty" else "pinentry-gnome3");
  in
    {
      defaultCacheTtl = 600;
      defaultCacheTtlSsh = 600;
      enable = true;
      enableExtraSocket = true;
      enableScDaemon = true;
      enableSshSupport = true;
      extraConfig = ''
        # Use different pinentry script depending on what is available.
        # Redirect through a script so this works on all distros.
        pinentry-program ${pinentry}
      '' + (
        optionalString enableLogging ''
          debug-level guru
          log-file socket:///${config.home.homeDirectory}/.gnupg/S.log
        ''
      );
      grabKeyboardAndMouse = true;
      maxCacheTtl = 7200;
      maxCacheTtlSsh = 7200;
      verbose = enableLogging;
    };

  # Tell SSH where to find GnuPG-Agent.
  programs.fish.interactiveShellInit = ''
    set -x SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
  '';
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
