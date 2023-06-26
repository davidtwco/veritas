{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    ./configs
    inputs.nixpkgs.nixosModules.notDetected
  ];

  boot = {
    # Enable running aarch64 binaries using qemu.
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Clean temporary directory on boot.
    cleanTmpDir = true;

    # Make memtest available as a boot option.
    loader = {
      grub.memtest86.enable = true;
      systemd-boot.memtest86.enable = true;
    };

    # Enable support for nfs and ntfs.
    supportedFilesystems = [ "cifs" "ntfs" "nfs" ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  environment = {
    pathsToLink = [ "/share/fish" "/share" ];
    systemPackages = with pkgs; [
      # Logitech Devices
      solaar
      ltunify

      # Steam Controller
      steamcontroller

      # Audit
      audit

      # Yubikey
      yubikey-personalization
      yubikey-manager
    ];
  };

  hardware.opengl = {
    driSupport32Bit = true;
    enable = true;
    extraPackages = with pkgs; [
      # VDPAU (hardware acceleration)
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  i18n.defaultLocale = "en_GB.UTF-8";

  nix = {
    settings =
      let
        nixConf = import ../../nix/conf.nix;
      in
      {
        "auto-optimise-store" = true;
        "substituters" = nixConf.binaryCaches;
        "trusted-public-keys" = nixConf.binaryCachePublicKeys;
      };
    sshServe.enable = true;
  };

  programs = {
    ccache.enable = true;
    bcc.enable = true;
    mosh = {
      enable = true;
      withUtempter = true;
    };
    nano.syntaxHighlight = true;
  };

  security = {
    audit.enable = true;
    auditd.enable = true;

    sudo.extraConfig = ''
      Defaults insults
    '';
  };

  services = {
    cron.enable = true;
    dbus.packages = with pkgs; [ dconf ];
    earlyoom = {
      enable = true;
      freeMemThreshold = 5;
    };
    fwupd.enable = true;
    locate.enable = true;
    # Required to let smart card mode of YubiKey to work.
    pcscd.enable = true;
    printing.enable = true;
    # Required for YubiKey devices to work.
    udev.packages = with pkgs; [ yubikey-personalization libu2f-host ];
  };

  # `nix-daemon` will hit the stack limit when using `nixFlakes`.
  systemd.services.nix-daemon.serviceConfig."LimitSTACK" = "infinity";

  time.timeZone = "Europe/London";

  veritas.configs = {
    networking.enable = true;
    user.enable = true;
  };

  # Silence warning about an invalid password hash.
  users.users.root.hashedPassword = null;
}
