{ config, pkgs, options, ... }:

# This file contains common configuration shared amongst all hosts.

let
  external = import ./external.nix;
in {
  nix = {
    # Automatically optimise the Nix store.
    autoOptimiseStore = true;
    # Add compatibility overlay to the $NIX_PATH, this overlay enables Nix tools (such as
    # `nix-shell`) to use the overlays defined in `nixpkgs.overlays`.
    nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nixos/compat.nix" ];
    # Enable serving packages over SSH when authenticated by the same keys as the `david` user.
    sshServe = {
      enable = true;
      keys = config.users.users.david.openssh.authorizedKeys.keys;
    };
  };

  imports = with external; [
    # Import shared configuration of overlays and nixpkgs.
    ./config.nix
    # Always create my user account and dotfiles.
    ./users/david
    # Enable home-manager.
    "${homeManager}/nixos"
    # Disable modules from 19.03 and use the versions from the unstable channel that match
    # versions we are using.
    "${unstableChannel}/nixos/modules/services/torrent/deluge.nix"
    "${unstableChannel}/nixos/modules/services/misc/lidarr.nix"
    "${unstableChannel}/nixos/modules/services/misc/jackett.nix"
    "${unstableChannel}/nixos/modules/services/misc/plex.nix"
  ];
  disabledModules = [
    "services/torrent/deluge.nix"
    "services/misc/jackett.nix"
    "services/misc/lidarr.nix"
    "services/misc/plex.nix"
  ];

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
    kbfs solaar ltunify steamcontroller yubikey-personalization yubikey-manager
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

  # Hardware {{{
  # ========
  hardware.opengl = {
    driSupport32Bit = true;
    enable = true;
    extraPackages = with pkgs; [
      # OpenCL
      intel-openclrt
      # VDPAU (hardware acceleration)
      vaapiIntel vaapiVdpau libvdpau-va-gl intel-media-driver
    ];
  };
  # }}}

  # Users {{{
  # ========
  # Do not allow users to be added or modified except through Nix configuration.
  users.mutableUsers = false;
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
