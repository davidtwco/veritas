{ config, pkgs, ... }:

# Need to run
#   sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable
# for this import to work correctly.
let
  unstable = import <unstable> {};
in {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # General System Utilities
    wget file unzip dmidecode

    # Dotfiles
    yadm unstable.antibody

    # Version Control
    git gnupg pinentry_ncurses

    # Development Environment
    vim tmux ctags alacritty

    # Browser
    firefox

    # Fonts
    meslo-lg
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.zsh.enable = true;
}
