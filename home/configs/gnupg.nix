{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.gnupg;
  homeDirectory = config.home.homeDirectory;

  wsl2-ssh-pageant = pkgs.fetchurl {
    url = "https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/download/v1.2.0/wsl2-ssh-pageant.exe";
    hash = "sha256-/iKUsFC3BFS7A47HuUqDV8RfjT1MUFpPN05KSVv8ryc=";
  };

  # Enable logging to a socket for debugging.
  # `watchgnupg --time-only --force ${config.home.homeDirectory}/.gnupg/S.log`
  enableLogging = false;
in
{
  options.veritas.configs.gnupg = {
    enable = mkEnableOption "gnupg configuration";

    pinentry = mkOption {
      type = types.str;
      default = "${pkgs.pinentry_gnome}/bin/pinentry-tty";
      description = "Program used for pinentry.";
    };

    withFishConfiguration = mkOption {
      type = types.bool;
      default = true;
      description = "Add configuration for GnuPG agent to fish.";
    };

    wslCompatibility = mkOption {
      type = types.bool;
      default = false;
      description = "Use npiperelay and wsl-pageant on WSL.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (
        writeScriptBin "gpg-backup-to-paper" ''
          #! ${runtimeShell} -e
          # Provide the path to the secret key as the first argument.
          NAME="$(${coreutils}/bin/basename $1 | ${coreutils}/bin/cut -d. -f1)"
          ${paperkey}/bin/paperkey --secret-key $1 --output-type raw | \
            ${coreutils}/bin/split -b 1500 - $NAME-
          for K in $NAME-*; do
              ${dmtx-utils}/bin/dmtxwrite -e 8 $K > $K.png
          done
        ''
      )
      (
        writeScriptBin "gpg-restore-to-paper" ''
          #! ${runtimeShell} -e
          # Pipe the datamatrix files concatenated. Provide the public key as the first argument and
          # filename as second argument.
          ${paperkey}/bin/paperkey --pubring $1 <&0 > $2.gpg
        ''
      )
    ];

    programs.gpg = {
      enable = true;
      settings = {
        # Set default key.
        "default-key" = "9F53F154";
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

    services.gpg-agent = {
      defaultCacheTtl = 600;
      defaultCacheTtlSsh = 600;
      enable = !cfg.wslCompatibility;
      enableExtraSocket = true;
      enableScDaemon = true;
      enableSshSupport = true;
      extraConfig = ''
        # Use different pinentry script depending on what is available.
        # Redirect through a script so this works on all distros.
        pinentry-program ${cfg.pinentry}
      '' + (
        optionalString enableLogging ''
          debug-level guru
          log-file socket:///${homeDirectory}/.gnupg/S.log
        ''
      );
      grabKeyboardAndMouse = true;
      maxCacheTtl = 7200;
      maxCacheTtlSsh = 7200;
      verbose = enableLogging;
    };

    # To be able to access the GPG and SSH of the Yubikey from within WSL 2, there is some setup
    # required. First, install gpg4win. Next, run the following commands:
    #
    # ```powershell
    # mkdir $env:APPDATA\gnupg
    # Add-Content -Path $env:APPDATA\gnupg\gpg-agent.conf -Encoding utf8 -Value "enable-putty-support`r`nenable-ssh-support"
    # Register-ScheduledJob -Name GpgAgent -Trigger (New-JobTrigger -AtLogOn) -Credential (Get-Credential) -RunNow -ScriptBlock {
    #   & "${env:ProgramFiles(x86)}/GnuPG/bin/gpg-connect-agent.exe" --options $env:APPDATA\gnupg\gpg-agent.conf /bye
    # }
    # ```
    #
    # On Linux, gpg-agent sockets are placed in `/run`, which is symlinked to
    # `$HOME/.gnupg/socketdir`. On Windows, sockets are forwarded using wsl2-ssh-pageant directly
    # to `$HOME/.gnupg/socketdir`. In either case, this provides a predictable path that can be
    # used by SSH configuration.
    #
    # NOTE: Unless socat was executed before `exec`ing into fish, it wouldn't launch the
    # `wsl2-ssh-pageant.exe` process.
    programs.bash.profileExtra = mkIf cfg.wslCompatibility ''
      mkdir -p ${homeDirectory}/.gnupg/socketdir

      if test ! -f "${homeDirectory}/.gnupg/wsl2-ssh-pageant.exe"; then
        cp ${wsl2-ssh-pageant} ${homeDirectory}/.gnupg/wsl2-ssh-pageant.exe
        chmod +x ${homeDirectory}/.gnupg/wsl2-ssh-pageant.exe
      fi

      export GPG_AGENT_SOCK=${homeDirectory}/.gnupg/S.gpg-agent
      ss -a | grep -q $GPG_AGENT_SOCK
      if [ $? -ne 0 ]; then
        rm -rf $GPG_AGENT_SOCK
        (setsid nohup socat UNIX-LISTEN:$GPG_AGENT_SOCK,fork EXEC:"$HOME/.gnupg/wsl2-ssh-pageant.exe --gpg S.gpg-agent",nofork >/dev/null 2>&1 &)
      fi

      export GPG_AGENT_EXTRA_SOCK=${homeDirectory}/.gnupg/socketdir/S.gpg-agent.extra
      ss -a | grep -q $GPG_AGENT_EXTRA_SOCK
      if [ $? -ne 0 ]; then
        rm -rf $GPG_AGENT_EXTRA_SOCK
        (setsid nohup socat UNIX-LISTEN:$GPG_AGENT_EXTRA_SOCK,fork EXEC:"$HOME/.gnupg/wsl2-ssh-pageant.exe --gpg S.gpg-agent.extra",nofork >/dev/null 2>&1 &)
      fi

      export SSH_AUTH_SOCK=${homeDirectory}/.gnupg/socketdir/S.gpg-agent.ssh
      ss -a | grep -q $SSH_AUTH_SOCK
      if [ $? -ne 0 ]; then
        rm -f $SSH_AUTH_SOCK
        (setsid nohup socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$HOME/.gnupg/wsl2-ssh-pageant.exe",nofork >/dev/null 2>&1 &)
      fi
    '';

    programs.fish = mkIf cfg.withFishConfiguration {
      # See comment above.
      interactiveShellInit = lib.mkAfter (optionalString (!cfg.wslCompatibility) ''
        set -x SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)

        if test ! -d "${homeDirectory}/.gnupg/socketdir"
          ${pkgs.coreutils}/bin/ln -s (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-socket) \
            "${homeDirectory}/.gnupg/socketdir"
        end
      '');
      shellAliases = with pkgs; {
        # Use this alias to make GPG need to unlock the key. `gpg-update-ssh-agent` would also want
        # to unlock the key, but the pinentry prompt mangles the terminal with that command.
        "gpg-unlock-key" =
          "echo 'foo' | ${gnupg}/bin/gpg -o /dev/null --local-user "
          + "${config.programs.git.signing.key} -as -";
        # Use this alias to make the GPG agent relearn what keys are connected and what keys they
        # have.
        "gpg-relearn-key" = "${gnupg}/bin/gpg-connect-agent \"scd serialno\" \"learn --force\" /bye";
        # > Set the startup TTY and X-DISPLAY variables to the values of this session. This command
        # > is useful to direct future pinentry invocations to another screen. It is only required
        # > because there is no way in the ssh-agent protocol to convey this information.
        "gpg-update-ssh-agent" = "${gnupg}/bin/gpg-connect-agent updatestartuptty /bye";
        # Use this alias to make sure everything is in working order. Need to unlock twice - if
        # `gpg-update-ssh-agent` called with an locked key then it will prompt for it to be unlocked
        # in a way that will mangle the terminal, therefore we need to unlock before this.
        "gpg-refresh" = "gpg-relearn-key && gpg-unlock-key && gpg-update-ssh-agent";
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
