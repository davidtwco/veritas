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
    wget file unzip dmidecode pstree

    # Dotfiles
    yadm unstable.antibody polybar

    # Version Control
    git gnupg pinentry_ncurses

    # Development Environment
    vim tmux ctags alacritty

    # Browser
    firefox

    # Chat Apps
    tdesktop

    # Keybase
    keybase kbfs
  ];

  # Fonts
  fonts.fonts = with pkgs; [
    meslo-lg source-code-pro source-sans-pro source-serif-pro font-awesome_5 inconsolata
    siji material-icons
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.zsh.enable = true;

  # Enable i3 support for polybar.
  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      polybar = pkgs.polybar.override {
        i3Support = true;
      };
    };
  };
}
