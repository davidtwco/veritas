{ config, pkgs, lib, ... }:

# This file contains the configuration for zsh.

let
  plugins = pkgs.callPackage ./plugins.nix {};
in {
  programs.zsh = {
    defaultKeymap = "viins";
    enable = true;
    history = {
      extended = true;
      ignoreDups = true;
      save = 10000000;
      share = false;
    };
    # On non-NixOS systems, need to manually source `nix.sh`.
    #
    # When the non-NixOS system is a WSL system, this goes through `.profile` because we can't
    # change shell with `chsh`. When it is not a WSL system, we go directly to `.zprofile`. So that
    # we don't duplicate this sourcing of `nix.sh`, we only set it in `.zprofile` and then pull it
    # in using the `config.programs.zsh` variable in the `.profile` definition (appending the shell
    # exec if WSL).
    profileExtra = lib.mkIf (config.veritas.david.dotfiles.isNonNixOS) (''
      if [ -f ${config.home.profileDirectory}/etc/profile.d/nix.sh ]; then
        . "${config.home.profileDirectory}/etc/profile.d/nix.sh"
      elif [ -f /etc/profile.d/nix.sh ]; then
        . "/etc/profile.d/nix.sh"
      fi
    '');
    initExtra = ''
      eval "$(${pkgs.starship-nightly}/bin/starship init zsh)"
      ${builtins.readFile ./colours.zsh}
      ${builtins.readFile ./completions.zsh}
    '' + (if config.veritas.david.dotfiles.isWsl then ''
      _run_npiperelay() {
          # This function will forward a named pipe from Windows to a socket in WSL. It expects
          # `npiperelay.exe` (from https://github.com/NZSmartie/npiperelay/releases) to exist at
          # `C:\npiperelay.exe`.
          SOCAT_PID_FILE="$1"
          SOCKET_PATH="$2"
          WINDOWS_PATH="$3"

          if [[ -f $SOCAT_PID_FILE ]] && kill -0 $(${pkgs.coreutils}/bin/cat $SOCAT_PID_FILE); then
              : # Already running.
          else
              rm -f "$SOCKET_PATH"
              EXEC="/mnt/c/npiperelay.exe -ei -ep -s -a '$WINDOWS_PATH'"
              (trap "rm $SOCAT_PID_FILE" EXIT; \
                ${pkgs.socat}/bin/socat UNIX-LISTEN:$SOCKET_PATH,fork EXEC:$EXEC,nofork \
                </dev/null &>/dev/null) &
              echo $! >$SOCAT_PID_FILE
          fi
      }

      if [ ! -d "${config.home.homeDirectory}/.gnupg/socketdir" ]; then
          # On Windows, symlink the directory that contains `S.gpg-agent.ssh` from
          # `wsl-pageant`. `npiperelay` will place `S.gpg-agent.extra` in this directory.
          # This will be the exact same locations that files are placed when running on
          # Linux, so that remote forwarding works.
          ${pkgs.coreutils}/bin/ln -s "/mnt/c/wsl-pageant" \
            "${config.home.homeDirectory}/.gnupg/socketdir"
      fi

      # When setting up GPG forwarding to WSL on Windows, get `npiperelay` (see comment in
      # `_run_npiperelay`) and `gpg4win`. Add a shortcut that runs at startup that will
      # launch the gpg-agent:
      #
      #   "C:\Program Files (x86)\GnuPG\bin\gpg-connect-agent.exe" /bye

      # Relay the primary GnuPG socket to `~/.gnupg/S.gpg-agent` which will be used by the
      # GPG agent.
      _run_npiperelay "${config.home.homeDirectory}/.gnupg/socat-gpg.pid" \
          "${config.home.homeDirectory}/.gnupg/S.gpg-agent" \
          "C:/Users/David/AppData/Roaming/gnupg/S.gpg-agent"

      # Relay the extra GnuPG socket to `~/.gnupg/S.gpg-agent.extra` which will be forwarded
      # to remote SSH hosts.
      _run_npiperelay "${config.home.homeDirectory}/.gnupg/socat-gpg-extra.pid" \
          "${config.home.homeDirectory}/.gnupg/socketdir/S.gpg-agent.extra" \
          "C:/Users/David/AppData/Roaming/gnupg/S.gpg-agent.extra"

      # When setting up SSH forwarding to WSL on Windows, get `wsl-ssh-pageant`
      # (https://github.com/benpye/wsl-ssh-pageant) and place it in `C:\wsl-pageant`. Add a
      # `wsl-pageant.vbs` script to the startup directory with the following contents:
      #
      # ```vbs
      # Set objFile = WScript.CreateObject("Scripting.FileSystemObject")
      # if objFile.FileExists("c:\wsl-pageant\S.gpg-agent.ssh") then
      #     objFile.DeleteFile "c:\wsl-pageant\S.gpg-agent.ssh"
      # end if
      # Set objShell = WScript.CreateObject("WScript.Shell")
      # objShell.Run( _
      #   "C:\wsl-pageant\wsl-ssh-pageant-amd64.exe --wsl c:\wsl-pageant\S.gpg-agent.ssh"), _
      #   0, True
      # ```

      # This file should exist because of `wsl-ssh-pageant`.
      export SSH_AUTH_SOCK="${config.home.homeDirectory}/.gnupg/socketdir/S.gpg-agent.ssh"
    '' else ''
      if [ ! -d "${config.home.homeDirectory}/.gnupg/socketdir" ]; then
          # On Linux, symlink this to the directory where the sockets are placed by the GPG
          # agent.
          # This needs to exist for the remote forwarding.
          ${pkgs.coreutils}/bin/ln -s "$(${pkgs.coreutils}/bin/dirname \
            "$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-socket)")" \
            "${config.home.homeDirectory}/.gnupg/socketdir"
      fi

      export GPG_TTY=$(tty)
      export SSH_AUTH_SOCK="$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)"
      if [ -z $SSH_CONNECTION ] && [ -z $SSH_CLIENT ]; then
          # Don't start the `gpg-agent` for remote connections. The sockets from the local
          # host will be forwarded and picked up by the gpg client.
          ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
      fi
    '') + ''
      # Bind keys for Surface and other strange keyboards.
      bindkey "^?" backward-delete-char
      bindkey "^W" backward-kill-word
      bindkey "^H" backward-delete-char
      bindkey "^U" backward-kill-line
      bindkey "[3~" delete-char
      bindkey "[7~" beginning-of-line
      bindkey "[1~" beginning-of-line
      bindkey "[8~" end-of-line
      bindkey "[4~" end-of-line

      # Disable control flow, allows CTRL+S to be used.
      stty -ixon

      # Treat the '!' character specially during expansion.
      setopt BANG_HIST
      # Write to the history file immediately, not when the shell exits.
      setopt INC_APPEND_HISTORY
      # Expire duplicate entries first when trimming history.
      setopt HIST_EXPIRE_DUPS_FIRST
      # Delete old recorded entry if new entry is a duplicate.
      setopt HIST_IGNORE_ALL_DUPS
      # Do not display a line previously found.
      setopt HIST_FIND_NO_DUPS
      # Don't record an entry starting with a space.
      setopt HIST_IGNORE_SPACE
      # Don't write duplicate entries in the history file.
      setopt HIST_SAVE_NO_DUPS
      # Remove superfluous blanks before recording entry.
      setopt HIST_REDUCE_BLANKS
      # Don't execute immediately upon history expansion.
      setopt HIST_VERIFY

      # Enable fasd integration.
      if [ "${pkgs.fasd}/bin/fasd" -nt "${config.xdg.cacheHome}/zsh/fasd" -o \
            ! -s "${config.xdg.cacheHome}/zsh/fasd" ]; then
          ${pkgs.fasd}/bin/fasd --init posix-alias zsh-hook zsh-ccomp \
            zsh-ccomp-install >| "${config.xdg.cacheHome}/fasd"
      fi

      # Define `fasd_cd` command.
      fasd_cd() {
        if [ $# -le 1 ]; then
          ${pkgs.fasd}/bin/fasd "$@"
        else
          local _fasd_ret="$(${pkgs.fasd}/bin/fasd -e echo "$@")"
          [ -z "$_fasd_ret" ] && return
          [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || echo "$_fasd_ret"
        fi
      }

      # If running in Neovim terminal mode then don't let us launch Neovim.
      if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
          alias nvim='echo "No nesting!"'
      fi

      # Use CTRL + ' ' to accept current autosuggestion.
      bindkey '^ ' autosuggest-accept

      # Enable yank, change, and delete whole line with 'Y', 'cc', and 'dd'.
      bindkey -M vicmd 'Y' vi-yank-whole-line

      # Enable undo/redo with `u`/`U`.
      bindkey -M vicmd 'u' undo
      bindkey -M vicmd 'U' redo

      # Comment out the command with `gcc` (like vim-commentary).
      bindkey -M vicmd 'gcc' vi-pound-insert

      # Use editor to edit command line with `CTRL-V`.
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd '^V' edit-command-line

      # Disable Ex mode with ':'.
      bindkey -rM vicmd ':'
    '';
    plugins = import ./plugins.nix;
    sessionVariables = let
    in {
      # Enable true colour and use a 256-colour terminal.
      "COLORTERM" = "truecolor";
      "TERM" = "xterm-256color";
      # 10ms for key sequences
      "KEYTIMEOUT" = "1";
      # Enable persistent REPL history for node.
      "NODE_REPL_HISTORY" = "${config.xdg.cacheHome}/node/history";
      # Use sloppy mode by default, matching web browsers.
      "NODE_REPL_MODE" = "sloppy";
      # Allow Vagrant to access Windows outside of WSL.
      "VAGRANT_WSL_ENABLE_WINDOWS_ACCESS" = "1";
      # Set a cache directory for zsh.
      "ZSH_CACHE_DIR" = "${config.xdg.cacheHome}/zsh";
      # Configure autosuggestions.
      "ZSH_AUTOSUGGEST_USE_ASYNC" = "1";
      "ZSH_AUTOSUGGEST_ACCEPT_WIDGETS" = "()";
    } // lib.attrsets.optionalAttrs config.veritas.david.dotfiles.isNonNixOS {
      # Needed for `home-manager switch` to work.
      "NIX_PATH" = "${config.home.homeDirectory}/.nix-defexpr/channels\${NIX_PATH:+:}$NIX_PATH";
    };
    shellAliases = {
      # Make `rm` prompt before removing more than three files or removing recursively.
      "rm" = "${pkgs.coreutils}/bin/rm -i";
      # Aliases that make commands colourful.
      "grep" = "${pkgs.gnugrep}/bin/grep --color=auto";
      "fgrep" = "${pkgs.gnugrep}/bin/fgrep --color=auto";
      "egrep" = "${pkgs.gnugrep}/bin/egrep --color=auto";
      # Aliases for `cat` to `bat`.
      "cat" = "${pkgs.bat}/bin/bat --paging=never -p";
      # Aliases for `ls` to `exa`.
      "ls" = "${pkgs.exa}/bin/exa";
      "dir" = "${pkgs.exa}/bin/exa";
      "ll" = "${pkgs.exa}/bin/exa -alF";
      "vdir" = "${pkgs.exa}/bin/exa -l";
      "la" = "${pkgs.exa}/bin/exa -a";
      "l" = "${pkgs.exa}/bin/exa -F";
      # Various aliases for `fasd`.
      "a" = "${pkgs.fasd}/bin/fasd -a";
      "s" = "${pkgs.fasd}/bin/fasd -si";
      "d" = "${pkgs.fasd}/bin/fasd -d";
      "f" = "${pkgs.fasd}/bin/fasd -f";
      "sd" = "${pkgs.fasd}/bin/fasd -sid";
      "sf" = "${pkgs.fasd}/bin/fasd -sif";
      "z" = "fasd_cd -d";
      "zz" = "fasd_cd -d -i";
      "v" = "${pkgs.fasd}/bin/fasd -f -e vim";
      # Extra Git subcommands for GitHub.
      "git" = "${pkgs.gitAndTools.hub}/bin/hub";
      # Build within a docker container with a rust and musl toolchain.
      "rust-musl-builder" =
        "${pkgs.docker}/bin/docker run --rm -it -v \"$PWD\":/home/rust/src " +
        "ekidd/rust-musl-builder:stable";
      # Use this alias to make GPG need to unlock the key. `gpg-update-ssh-agent` would also want
      # to unlock the key, but the pinentry prompt mangles the terminal with that command.
      "gpg-unlock-key" =
        "echo 'foo' | ${pkgs.gnupg}/bin/gpg -o /dev/null --local-user " +
        "${config.programs.git.signing.key} -as -";
      # Use this alias to make the GPG agent relearn what keys are connected and what keys they
      # have.
      "gpg-relearn-key" = "${pkgs.gnupg}/bin/gpg-connect-agent 'scd serialno' 'learn --force' /bye";
      # > Set the startup TTY and X-DISPLAY variables to the values of this session. This command
      # > is useful to direct future pinentry invocations to another screen. It is only required
      # > because there is no way in the ssh-agent protocol to convey this information.
      "gpg-update-ssh-agent" = "${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye";
      # Use this alias to make sure everything is in working order. Need to unlock twice - if
      # `gpg-update-ssh-agent` called with an locked key then it will prompt for it to be unlocked
      # in a way that will mangle the terminal, therefore we need to unlock before this.
      "gpg-refresh" = "gpg-relearn-key && gpg-unlock-key && gpg-update-ssh-agent";
      # Fairly self explanatory, prints the current external IP address.
      "what-is-my-ip" = "${pkgs.dnsutils}/bin/dig +short myip.opendns.com @resolver1.opendns.com";
      # `<command> | sprunge` will make a quick link to send.
      "sprunge" = "${pkgs.curl}/bin/curl -F 'sprunge=<-' http://sprunge.us";
      # Stop printing the version number on gdb startup.
      "gdb" = "gdb -q";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
