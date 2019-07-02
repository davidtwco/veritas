{ config, pkgs, options, ... }:

let
  # Update these periodically (or when PRs land).
  unstableChannel = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs-channels.git";
    ref = "nixos-unstable";
    rev = "73392e79aa62e406683d6a732eb4f4101f4732be";
  };
  mozillaOverlay = builtins.fetchGit {
    url = "https://github.com/mozilla/nixpkgs-mozilla.git";
    ref = "master";
    rev = "200cf0640fd8fdff0e1a342db98c9e31e6f13cd7";
  };
  # Fetch branches that contain open PRs to nixpkgs upstream and use modules from those instead of
  # hacky workarounds. These should be removed as PRs land and the unstable channel is updated.
  delugeModuleFork = builtins.fetchGit {
    url = "https://github.com/davidtwco/nixpkgs.git";
    ref = "deluge/users-groups-firewalls";
    rev = "16c394fe0f46935a4065a5a1ed43ef1cabd5840a";
  };
  lidarrModuleFork = builtins.fetchGit {
    url = "https://github.com/davidtwco/nixpkgs.git";
    ref = "lidarr/users-groups-firewalls";
    rev = "6ba90c2aae05ca64acac8ffe01c4c2b72d2be6a8";
  };
in
  {
    # Automatically optimise the Nix store.
    nix.autoOptimiseStore = true;
    # Add `./overlay.nix` to the overlays used by NixOS. `nixpkgs.overlays` is the canonical list
    # of overlays used in the system. It will be used by Nix tools due to the compatability overlay
    # included in the $NIX_PATH below.
    nixpkgs.overlays = [ (import ./overlay.nix) (import mozillaOverlay) ];
    # Add compatibility overlay to the $NIX_PATH, this overlay enables Nix tools (such as
    # `nix-shell`) to use the overlays defined in `nixpkgs.overlays`.
    nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nixos/compat.nix" ];
    # Allow unfree packages.
    nixpkgs.config.allowUnfree = true;
    # Enable the unstable channel.
    nixpkgs.config.packageOverrides = pkgs: {
      unstable = import unstableChannel {
        config = config.nixpkgs.config;
      };
    };

    # Disable modules from 19.03 and use the versions from the unstable channel that match
    # versions we are using.
    imports = [
      "${delugeModuleFork}/nixos/modules/services/torrent/deluge.nix"
      "${lidarrModuleFork}/nixos/modules/services/misc/lidarr.nix"
      "${unstableChannel}/nixos/modules/services/misc/plex.nix"
    ];
    disabledModules = [
      "services/torrent/deluge.nix"
      "services/misc/lidarr.nix"
      "services/misc/plex.nix"
    ];

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
    environment.pathsToLink = [ "/share" ];

    environment.systemPackages = with pkgs; [
      # General utilities
      nix-prefetch-scripts file which nix-index hyperfine tokei cron direnv moreutils wget bc
      pkgconfig idutils lorri nixfmt keepassxc

      # Archiving
      unzip zip unrar p7zip dtrx

      # Processes/debugging/monitoring
      pstree htop iotop powertop ltrace strace binutils lshw linuxPackages.perf pciutils psmisc
      pmutils dmidecode usbutils

      # Networking
      inetutils mosh bmon bind conntrack-tools tcpdump ethtool linuxPackages.bpftrace

      # Disks
      parted exfat dosfstools ncdu smartmontools

      # Man pages
      man man-pages posix_man_pages stdman

      # Dotfiles
      yadm antibody fasd pinentry_ncurses vim neovim tmux universal-ctags ripgrep exa neofetch

      # Version Control
      git git-lfs gitAndTools.hub patchutils

      # GnuPG
      haskellPackages.hopenpgp-tools gnupg

      # Keybase
      keybase kbfs

      # Hardware
      solaar ltunify steamcontroller yubikey-personalization yubikey-manager
    ];

    programs = {
      adb.enable = true;
      bcc.enable = true;
      wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
    };
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

      # Required to let smart card mode of YubiKey to work.
      pcscd.enable = true;

      # Enable CUPS for printing.
      printing.enable = true;

      # Enable Keybase.
      keybase.enable = true;
      kbfs.enable = true;

      udev.packages = with pkgs; [
        # Required for YubiKey devices to work.
        yubikey-personalization libu2f-host
      ];
    };
    # }}}

    # Sudo {{{
    # ====
    security.sudo.extraConfig = ''
      Defaults insults
    '';
    # }}}
  }

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
