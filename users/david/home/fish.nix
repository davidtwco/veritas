{ pkgs, config, lib, ... }:

# This file contains the configuration for fish.

with lib;
{
  programs.fish = {
    enable = true;
    interactiveShellInit = with config.veritas.david.colourScheme.basic; ''
      # Disable the greeting message.
      set fish_greeting

      # Set environment variables.
      set -x COLORTERM truecolor
      set -x TERM xterm-256color

      # Use vi keybinds.
      fish_vi_key_bindings

      # Use hybrid colour scheme.
      set fish_color_autosuggestion ${white}
      set fish_color_command ${brightYellow}
      set fish_color_comment ${brightGreen}
      set fish_color_cwd ${green}
      set fish_color_cwd_root ${red}
      set fish_color_end ${brightMagenta}
      set fish_color_error ${brightRed}
      set fish_color_escape ${brightCyan}
      set fish_color_operator ${brightCyan}
      set fish_color_param ${green}
      set fish_color_quote ${brightGreen}
      set fish_color_redirection ${cyan}
      set fish_color_status ${red}
      set fish_color_user ${brightGreen}
      set fish_color_description ${magenta}
    '' + (
      optionalString config.veritas.david.dotfiles.isNonNixOS ''
        # Needed for `home-manager switch` to work.
        set -x NIX_PATH ${config.home.homeDirectory}/.nix-defexpr/channels\''${NIX_PATH:+:}$NIX_PATH
      ''
    );
    package = pkgs.unstable.fish;
    shellAliases = with pkgs; {
      # Make `rm` prompt before removing more than three files or removing recursively.
      "rm" = "${coreutils}/bin/rm -i";
      # Aliases that make commands colourful.
      "grep" = "${gnugrep}/bin/grep --color=auto";
      "fgrep" = "${gnugrep}/bin/fgrep --color=auto";
      "egrep" = "${gnugrep}/bin/egrep --color=auto";
      # Aliases for `cat` to `bat`.
      "cat" = "${bat}/bin/bat --paging=never -p";
      # Aliases for `ls` to `exa`.
      "ls" = "${exa}/bin/exa";
      "dir" = "${exa}/bin/exa";
      "ll" = "${exa}/bin/exa -alF";
      "vdir" = "${exa}/bin/exa -l";
      "la" = "${exa}/bin/exa -a";
      "l" = "${exa}/bin/exa -F";
      # Extra Git subcommands for GitHub.
      "git" = "${gitAndTools.hub}/bin/hub";
      # Build within a docker container with a rust and musl toolchain.
      "rust-musl-builder" =
        "${docker}/bin/docker run --rm -it -v \"$PWD\":/home/rust/src "
        + "ekidd/rust-musl-builder:stable";
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
      # Fairly self explanatory, prints the current external IP address.
      "what-is-my-ip" = "${dnsutils}/bin/dig +short myip.opendns.com @resolver1.opendns.com";
      # `<command> | sprunge` will make a quick link to send.
      "sprunge" = "${curl}/bin/curl -F \"sprunge=<-\" http://sprunge.us";
      # Stop printing the version number on gdb startup.
      "gdb" = "gdb -q";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
