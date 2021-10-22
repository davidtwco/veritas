{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.fish;

  lscolors = pkgs.fetchgit {
    url = "https://github.com/trapd00r/LS_COLORS.git";
    rev = "034aee597117492778c9223b7e2188ed6a5bef54";
    sha256 = "sha256-fq9nDGHSz/xjHYtioQzt2O/oxn55kWV+PgRFa6fzlXM=";
  };
in
{
  options.veritas.configs.fish = {
    enable = mkEnableOption "fish configuration";

    withDeveloperTools = mkOption {
      type = types.bool;
      default = false;
      description = "Enable development-specific aliases/configuration.";
    };

    homeManagerOnlyCompatibility = mkOption {
      type = types.bool;
      default = false;
      description = "Add configuration for non-NixOS home-manager only systems.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (
        writeScriptBin "print-fish-colours" ''
          #! ${fish}/bin/fish
          set -l clr_list (set -n | grep fish | grep color | grep -v __)
          if test -n "$clr_list"
            set -l bclr (set_color normal)
            set -l bold (set_color --bold)
            printf "\n| %-35s | %-35s |\n" Variable Definition
            echo '|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|'
            for var in $clr_list
              set -l def $$var
              set -l clr (set_color $def ^/dev/null)
              or begin
                printf "| %-35s | %s%-35s$bclr |\n" "$var" (set_color --bold white --background=red) "$def"
                continue
              end
              printf "| $clr%-35s$bclr | $bold%-35s$bclr |\n" "$var" "$def"
            end
            echo '|_____________________________________|_____________________________________|'\n
          end
        ''
      )
    ];

    programs.fish = {
      enable = true;
      interactiveShellInit = with config.veritas.profiles.common.colourScheme; ''
        # Disable the greeting message.
        set fish_greeting

        # Set environment variables.
        set -x COLORTERM truecolor
        set -x TERM xterm-256color
        eval (${pkgs.coreutils}/bin/dircolors -c ${lscolors}/LS_COLORS)

        # Use vi keybinds.
        fish_vi_key_bindings

        # Accept autosuggestions with CTRL+SPACE
        bind -k nul accept-autosuggestion
        bind -M insert -k nul accept-autosuggestion

        # Make sure HOME + END works as expected everywhere
        bind \e\[1~ beginning-of-line
        bind -M insert \e\[1~ beginning-of-line
        bind \e\[4~ end-of-line
        bind -M insert \e\[4~ end-of-line
        bind \e\[7~ beginning-of-line
        bind -M insert \e\[7~ beginning-of-line
        bind \e\[8~ end-of-line
        bind -M insert \e\[8~ end-of-line
        bind \eOH beginning-of-line
        bind -M insert \eOH beginning-of-line
        bind \eOF end-of-line
        bind -M insert \eOF end-of-line
        bind \e\[H beginning-of-line
        bind -M insert \e\[H beginning-of-line
        bind \e\[F end-of-line
        bind -M insert \e\[F end-of-line

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
      '';
      package = pkgs.fish;
      shellAliases = with pkgs; {
        # Make `rm` prompt before removing more than three files or removing recursively.
        "rm" = "${coreutils}/bin/rm -i";
        # Aliases that make commands colourful.
        "grep" = "${gnugrep}/bin/grep --color=auto";
        "fgrep" = "${gnugrep}/bin/fgrep --color=auto";
        "egrep" = "${gnugrep}/bin/egrep --color=auto";
        # Aliases for `cat` to `bat`.
        "cat" = "${bat}/bin/bat --theme TwoDark --paging never";
        # Aliases for `ls` to `exa`.
        "ls" = "${exa}/bin/exa";
        "dir" = "${exa}/bin/exa";
        "ll" = "${exa}/bin/exa -alF";
        "vdir" = "${exa}/bin/exa -l";
        "la" = "${exa}/bin/exa -a";
        "l" = "${exa}/bin/exa -F";
        # `<command> | sprunge` will make a quick link to send.
        "sprunge" = "${curl}/bin/curl -F \"sprunge=<-\" http://sprunge.us";
      } // mkIf cfg.withDeveloperTools {
        # Extra Git subcommands for GitHub.
        "git" = "${gitAndTools.hub}/bin/hub";
        # Stop printing the version number on gdb startup.
        "gdb" = "gdb -q";
        # Build within a docker container with a rust and musl toolchain.
        "rust-musl-builder" =
          "${docker}/bin/docker run --rm -it -v \"$PWD\":/home/rust/src "
            + "ekidd/rust-musl-builder:stable";
        # Fairly self explanatory, prints the current external IP address.
        "what-is-my-ip" = "${dnsutils}/bin/dig +short myip.opendns.com @resolver1.opendns.com";
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
