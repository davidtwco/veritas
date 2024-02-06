{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./configs
  ];

  home = {
    enableDebugInfo = true;

    file = {
      ".ccache/ccache.conf".text = ''
        compression = true
        max_size = 50G
      '';

      ".hushlogin".text = ''
        # The mere presence of this file in the home directory disables the system
        # copyright notice, the date and time of the last login, the message of the
        # day as well as other information that may otherwise appear on login.
        # See `man login`.
      '';

      # Allow scrolling left and right with `h` and `l` in `less`.
      ".lesskey".text = ''
        h left-scroll
        l right-scroll
      '';
    };

    keyboard.layout = "gb";
    language.base = "en_GB.utf8";

    packages = with pkgs; [
      home-manager
      # Determine file type.
      file
      # Show full path of shell commands.
      which
      # Non-interactive network downloader.
      wget
      # List directory contents in tree-like format.
      tree
      # Interactive process viewer.
      htop
      # Mobile shell with roaming and intelligent local echo.
      mosh
      # Copy files/archives/repositories into the nix store.
      nix-prefetch-scripts
      # Index the nix store (provides `nix-locate`).
      nix-index
      # Eases nixpkgs review workflow.
      nixpkgs-review
      # grep alternative.
      ripgrep
      # ls alternative.
      eza
      # cat alternative.
      bat
      # A command-line tool to generate, analyze, convert and manipulate colors.
      pastel
      # Tool for indexing, slicing, analyzing, splitting and joining CSV files.
      xsv
      # Simple, fast and user-friendly alternative to find.
      fd
      # More intuitive du.
      du-dust
      # cat for markdown
      mdcat
      # Hosted binary caches
      cachix
      # Show information about the current system
      neofetch
      # Alternative version control systems.
      mercurial
      breezy
      subversion
      pijul
      # Incremental git merging/rebasing.
      gitAndTools.git-imerge
      # Remove large files from repositories.
      gitAndTools.git-filter-repo
      # Tools for manipulating patch files.
      patchutils
      # Benchmarking.
      hyperfine
      # Codebase statistics.
      tokei
      # Utility for creating gists from stdout.
      gist
      # DNS client
      dogdns
      # Socket forwarding
      socat
      # Nix language server
      nil
      # Nix formatter
      nixpkgs-fmt
      # Rust toolchain
      rustup
      # Python
      python3
      # GitHub CLI
      gh
    ] ++ (optional stdenv.isLinux [
      # Used by `breakpointHook` in nixpkgs.
      cntr
      # Power consumption and management diagnosis tool.
      powertop
      # Top-like I/O monitor.
      iotop
      # List hardware.
      lshw
      # Collection of programs for inspecting/manipulating configuration of PCI devices.
      pciutils
      # Collection of utilities using proc filesystem (`pstree`, `killall`, etc.)
      psmisc
      # DMI table decoder.
      dmidecode
      # Tools for working with usb devices (`lsusb`, etc.)
      usbutils
      # Collection of common network programs.
      inetutils
      # Bandwidth monitor and rate estimator.
      bmon
      # DNS server (provides `dig`)
      bind
      # Connection tracking userspace tools.
      conntrack-tools
      # Dump traffic on a network.
      tcpdump
      # Query/control network driver and hardware settings.
      ethtool
      # Parititon manipulation program.
      parted
      # exFAT filesystem implementation.
      exfat
      # Utilities for creating/checking FAT/VFAT filesystems.
      dosfstools
      # ncurses disk usage.
      ncdu
      # Hard-drive health monitoring.
      smartmontools
      # Tool for discovering and probing hosts on a computer network
      arping
      # Dependency mgmt for nix projects
      niv
      # Visualize Nix gc-roots to delete to free space.
      nix-du
      # Reading hardware sensors.
      lm_sensors
      # NFS debugging utilities
      nfs-utils
      # Recover dead disks :(
      ddrescue
      # Query SNMP servers
      net_snmp
      # Required to mount encrypted USB drives.
      cryptsetup
      # Check which process is using a mountpoint.
      lsof
      # Locales!
      glibcLocales
      # Compress/uncompress `.zip` files.
      unzip
      zip
      # Uncompress `.rar` files.
      unrar
      # Daemon to execute scheduled commands.
      cron
      # Library call tracer.
      ltrace
      # System call tracer.
      strace
      # Performance analysis tools.
      linuxPackages.perf
    ]);

    sessionVariables = {
      "EDITOR" = "hx";
      "LESS" = "-R --mouse";
      "LESSCHARSET" = "utf-8";

      # Don't clear the screen when leaving man.
      "MANPAGER" = "less -X";
    } // (optionalAttrs pkgs.stdenv.isLinux {
      "LOCALE_ARCHIVE" = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      "LANGUAGE" = config.home.language.base;
      "LC_ALL" = config.home.language.base;
    });
  };

  # Install home-manager manpages.
  manual.manpages.enable = true;

  programs = {
    direnv.enable = true;
    jq.enable = true;

    # Install man output for any Nix packages.
    man.enable = true;
  };

  veritas.configs = {
    fish.enable = true;
    fzf.enable = true;
    gdb.enable = true;
    git.enable = true;
    helix.enable = true;
    readline.enable = true;
    ssh.enable = true;
    starship.enable = true;
    tmux.enable = true;
  };

  xdg = {
    configFile."flake8".text = ''
      [flake8]
      # Recommend matching the black line length (default 88),
      # rather than using the flake8 default of 79:
      max-line-length = 88
      extend-ignore =
          # See https://github.com/PyCQA/pycodestyle/issues/373
          E203,
    '';

    enable = true;
    mime.enable = pkgs.stdenv.isLinux;
  };
}
