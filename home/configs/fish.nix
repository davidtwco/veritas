{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.fish;

  lscolors = pkgs.fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "7271a7a8135c1e8a82584bfc9a8ebc227c5c6b2b";
    sha256 = "0gs2qmdxvvgs5ck2j8b6i8dqc5q91m8xrvc2ajvlhcr7in0n9iw5";
  };
in
{
  options.veritas.configs.fish = {
    enable = mkEnableOption "fish configuration";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        # Add Nix profile to the $PATH, idempotent and only required for non-NixOS hosts.
        fish_add_path ~/.nix-profile/bin/

        # Add Cargo to the $PATH
        fish_add_path ~/.cargo/bin/

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
        set fish_color_autosuggestion 707880
        set fish_color_command F0C674
        set fish_color_comment B5BD68
        set fish_color_cwd 8C9440
        set fish_color_cwd_root A54242
        set fish_color_end B294BB
        set fish_color_error CC6666
        set fish_color_escape 8ABEB7
        set fish_color_operator 8ABEB7
        set fish_color_param 8C9440
        set fish_color_quote B5BD68
        set fish_color_redirection 5E8D87
        set fish_color_status A54242
        set fish_color_user B5BD68
        set fish_color_description 85678F
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
        "cat" = "${bat}/bin/bat --theme OneHalfDark -pp";
        # Aliases for `ls` to `eza`.
        "ls" = "${eza}/bin/eza";
        "dir" = "${eza}/bin/eza";
        "ll" = "${eza}/bin/eza -alF";
        "vdir" = "${eza}/bin/eza -l";
        "la" = "${eza}/bin/eza -a";
        "l" = "${eza}/bin/eza -F";
        # Fairly self explanatory, prints the current external IP address.
        "what-is-my-ip" = "${dnsutils}/bin/dig +short myip.opendns.com @resolver1.opendns.com";
      };
    };
  };
}
