{ config, pkgs, ... }:

{
  # Automatically optimise the Nix store.
  nix.autoOptimiseStore = true;
  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Enable serving packages over SSH when authenticated by the same keys as the `david` user.
  nix.sshServe.enable = true;
  nix.sshServe.keys = config.users.extraUsers.david.openssh.authorizedKeys.keys;

  # Boot {{{
  # ====
  boot.cleanTmpDir = true;
  # }}}

  # i18n {{{
  # ====
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  time.timeZone = "Europe/London";
  # }}}

  # Packages {{{
  # ========
  environment.systemPackages = with pkgs; [
    # General utilities
    wget file unzip zip unrar p7zip dmidecode pstree dtrx htop iotop powertop ltrace strace
    linuxPackages.perf pciutils lshw smartmontools usbutils inetutils wireshark
    nix-prefetch-scripts pmutils psmisc which binutils bc exfat dosfstools patchutils moreutils
    ncdu bmon nix-index exa neofetch mosh pkgconfig direnv cron tree tokei hyperfine

    # Man pages
    man man-pages posix_man_pages stdman

    # Dotfiles
    yadm antibody fasd pinentry_ncurses

    # Keybase
    keybase kbfs

    # Hardware
    solaar ltunify steamcontroller
  ];
  # }}}

  # Shell {{{
  # ========
  programs.zsh.enable = true;
  # }}}

  # Services {{{
  # ========
  services = {
    # Enable cron jobs.
    cron.enable = true;

    # Enable user services.
    dbus.socketActivated = true;

    # Enable locate to find files quickly.
    locate.enable = true;

    # Enable CUPS for printing.
    printing.enable = true;

    udev.packages = with pkgs; [
      # Required for android devices in `/dev` to have correct access levels.
      android-udev-rules
    ];
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
