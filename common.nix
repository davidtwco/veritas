{ config, pkgs, options, ... }:

let
  unstableTarball =
    fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
  {
    # Nix {{{
    # ===
    nix = {
      # Automatically optimise the Nix store.
      autoOptimiseStore = true;
      # Add compatibility overlay to the $NIX_PATH, this overlay enables Nix tools (such as
      # `nix-shell`) to use the overlays defined in `nixpkgs.overlays`.
      nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nixos/compat.nix" ];
      # Enable serving packages over SSH when authenticated by the same keys as the `david` user.
      sshServe = {
        enable = true;
        keys = config.users.extraUsers.david.openssh.authorizedKeys.keys;
      };
    };

    nixpkgs.config = {
      # Allow unfree packages.
      allowUnfree = true;
      # Add `./overlay.nix` to the overlays used by NixOS. `nixpkgs.overlays` is the canonical list
      # of overlays used in the system. It will be used by Nix tools due to the compatability overlay
      # included in the $NIX_PATH below.
      overlays = [ (import ./overlay.nix) ];
      # Enable the unstable channel.
      packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
        };
      };
    };
    # }}}

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
