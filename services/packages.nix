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
    # General Utilities
    wget file unzip zip unrar p7zip dmidecode pstree dtrx
    htop iotop powertop ltrace strace linuxPackages.perf
    pciutils lshw smartmontools usbutils inetutils wireshark
    nix-prefetch-scripts pmutils psmisc which binutils bc
    exfat dosfstools patchutils moreutils ncdu bmon nix-index exa
    neofetch

    # Desktop Utilities
    scrot xsel xlibs.xbacklight arandr pavucontrol paprefs xclip
    gnome3.gnome-tweak-tool

    # Man Pages
    man man-pages posix_man_pages stdman

    # Dotfiles
    yadm unstable.antibody polybar rofi

    # Version Control
    git gnupg pinentry_ncurses mercurial bazaar subversion

    # Development Environment
    vim tmux ctags alacritty rustup ripgrep llvm nix-repl
    silver-searcher neovim jekyll ruby rubocop travis doxygen
    pipenv jetbrains.pycharm-community pypy pythonFull python2Full
    python27Packages.virtualenv python36Packages.virtualenv
    valgrind gdb rr llvmPackages.libclang

    # Browser
    firefox

    # Chat Apps
    tdesktop weechat slack discord hipchat riot-web signal-desktop

    # Keybase
    keybase kbfs keybase-gui

    # Desktop Themes
    arc-icon-theme arc-kde-theme arc-theme

    # Academic
    texlive.combined.scheme-basic git-latexdiff proselint pandoc
  ];

  # Fonts
  fonts.fonts = with pkgs; [
    meslo-lg source-code-pro source-sans-pro source-serif-pro font-awesome_5 inconsolata
    siji material-icons powerline-fonts roboto roboto-mono roboto-slab
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.zsh.enable = true;

  # Enable i3 support for polybar.
  nixpkgs.config = {
    # Allow awful unfree stuff.
    allowUnfree = true;

    packageOverrides = pkgs: rec {
      polybar = pkgs.polybar.override {
        i3Support = true;
      };
    };
  };

  # Clean temporary directory.
  boot.cleanTmpDir = true;

  services = {
    udev.packages = with pkgs; [
      # Required for android devices in `/dev` to have correct access levels.
      android-udev-rules
    ];

    # Enable locate to find files quickly.
    locate.enable = true;

    # Enable CUPS for printing.
    printing.enable = true;

    # Enable TLP for better power management.
    tlp.enable = true;

    # Enable user services.
    dbus.socketActivated = true;
  };

  # Use libvirtd to manage virtual machines.
  virtualisation.libvirtd.enable = true;

  # Enable docker.
  virtualisation.docker.enable = true;

}
