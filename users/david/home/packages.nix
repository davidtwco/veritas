{ pkgs, ... }:

# This file contains the configuration for default-installed packages.

{
  home.packages = with pkgs; [
    # Determine file type.
    file
    # Show full path of shell commands.
    which
    # Daemon to execute scheduled commands.
    cron
    # Collection of useful tools that aren't coreutils.
    moreutils
    # Non-interactive network downloader.
    wget
    # Return metainformation about installed libraries.
    pkgconfig
    # Tools for querying id database.
    idutils
    # List directory contents in tree-like format.
    tree
    # Interactive process viewer.
    htop
    # Top-like I/O monitor.
    iotop
    # Power consumption and management diagnosis tool.
    powertop
    # Library call tracer.
    ltrace
    # System call tracer.
    strace
    # Tools for manipulating binaries.
    binutils
    # List hardware.
    lshw
    # Performance analysis tools.
    linuxPackages.perf
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
    # Mobile shell with roaming and intelligent local echo.
    mosh
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
    # eBPF tracing language and frontend.
    linuxPackages.bpftrace
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
    # Compress/uncompress `.zip` files.
    unzip zip
    # Uncompress `.rar` files.
    unrar
    # Compress/uncompress `.7z` files.
    p7zip
    # Man pages
    man man-pages posix_man_pages stdman
    # Benchmarking.
    hyperfine
    # Codebase statistics.
    tokei
    # Source `.envrc` when entering a directory.
    direnv
    # Improved nix-shell.
    lorri
    # Arbitrary-precision calculator.
    bc
    # Password manager.
    keepassxc
    # Copy files/archives/repositories into the nix store.
    nix-prefetch-scripts
    # Index the nix store (provides `nix-locate`).
    nix-index
    # Eases nixpkgs review workflow.
    nix-review
    # grep alternative.
    ripgrep
    # ls alternative.
    exa
    # cat alternative.
    bat
    # Git wrapper that provides GitHub specific commands.
    gitAndTools.hub
    # Quicker access to files and directories.
    fasd
    # Incremental git merging/rebasing.
    gitAndTools.git-imerge
    # Tools for manipulating patch files.
    patchutils
    # Alternative version control systems.
    mercurial bazaar subversion
    # GnuPG
    gnupg
    # Keybase
    keybase
    # Utility for creating gists from stdout.
    gist
    # Personal project for managing working directories.
    workman
    # A command-line tool to generate, analyze, convert and manipulate colors.
    pastel
    # ClusterSSH with tmux.
    tmux-cssh
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
