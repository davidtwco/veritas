{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.common;

  list-iommu-groups = (
    writeScriptBin "list-iommu-groups" ''
      #! ${pkgs.runtimeShell} -e
      shopt -s nullglob
      for g in /sys/kernel/iommu_groups/*; do
        echo "IOMMU Group ''${g##*/}:"
        for d in $g/devices/*; do
          echo -e "\t$(lspci -nns ''${d##*/})"
        done;
      done;
    ''
  );
in
{
  options.veritas.profiles.common = {
    enable = mkEnableOption "common configurations";

    # Define a colour scheme for use in application configurations to ensure consistency.
    colourScheme =
      let
        mkColour = description: default: mkOption {
          inherit default;
          description = "Define the colour for ${description}.";
          example = "FFFFFF";
          type = types.str;
        };
      in
      {
        background = mkColour "background" "1C1C1C";
        cursor = mkColour "foreground" cfg.colourScheme.foreground;
        foreground = mkColour "foreground" "C5C8C6";

        # Regular colours
        black = mkColour "black" "282A2E";
        red = mkColour "red" "A54242";
        green = mkColour "green" "8C9440";
        yellow = mkColour "yellow" "DE935F";
        blue = mkColour "blue" "5F819D";
        magenta = mkColour "magenta" "85678F";
        cyan = mkColour "cyan" "5E8D87";
        white = mkColour "white" "707880";

        # Bright colours
        brightBlack = mkColour "bright black" "373B41";
        brightRed = mkColour "bright red" "CC6666";
        brightGreen = mkColour "bright green" "B5BD68";
        brightYellow = mkColour "bright yellow" "F0C674";
        brightBlue = mkColour "bright blue" "81A2BE";
        brightMagenta = mkColour "bright magenta" "B294BB";
        brightCyan = mkColour "bright cyan" "8ABEB7";
        brightWhite = mkColour "bright white" "C5C8C6";
      };

    withTools = mkOption {
      type = types.str;
      default = true;
      description = "Install helpful tools and utilities for debugging.";
    };
  };

  config = mkIf cfg.enable {
    home = {
      enableDebugInfo = true;
      keyboard.layout = "gb";
      language.base = "en_GB.utf8";
      packages = with pkgs; [
        # Determine file type.
        file
        # Show full path of shell commands.
        which
        # Collection of useful tools that aren't coreutils.
        moreutils
        # Non-interactive network downloader.
        wget
        # List directory contents in tree-like format.
        tree
        # Interactive process viewer.
        htop
        # Mobile shell with roaming and intelligent local echo.
        mosh
        # Man pages
        man
        man-pages
        posix_man_pages
        stdman
        # Arbitrary-precision calculator.
        bc
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
        # Quicker access to files and directories.
        fasd
        # GnuPG
        gnupg
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
        # Command line image viewer
        viu
        # Encrypted files in Git repositories
        git-crypt
        # Hosted binary caches
        cachix
        # Show information about the current system
        neofetch
      ] ++ (optional stdenv.isLinux [
        # Power consumption and management diagnosis tool.
        powertop
        # Top-like I/O monitor.
        iotop
        # Helper script to print the IOMMU groups of PCI devices.
        list-iommu-groups
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
      ]);

      sessionVariables = {
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

    # Install man output for any Nix packages.
    programs.man.enable = true;

    veritas.configs = {
      bash.enable = true;
      cachix.enable = true;
      command-not-found.enable = true;
      feh.enable = true;
      fish.enable = true;
      fzf.enable = true;
      git.enable = true;
      gnupg.enable = true;
      helix.enable = true;
      htop.enable = true;
      hushlogin.enable = true;
      info.enable = true;
      jq.enable = true;
      less.enable = true;
      mail.enable = true;
      neovim.enable = true;
      netrc.enable = true;
      readline.enable = true;
      ssh.enable = true;
      starship.enable = true;
      tmux.enable = true;
      xdg.enable = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
