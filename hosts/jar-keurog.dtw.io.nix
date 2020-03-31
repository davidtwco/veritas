{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 24;

  imports = [ ../common.nix ];

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    initrd = {
      # Modules that are available to be loaded during initial ramdisk.
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      # Modules that are loaded during initial ramdisk.
      kernelModules = [ "dm-snapshot" ];
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      # NVIDIA
      "nomodeset"
      "video=vesa:off"
      "vga=normal"
    ];
    # Modules available during second stage of the boot process.
    kernelModules = [
      # Wi-Fi
      "iwlwifi"
    ];
    vesa = false;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a449eeb7-aaf0-4b82-968c-519ff2c94a89";
      fsType = "btrfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/AA8B-F94D";
      fsType = "vfat";
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    nvidia.modesetting.enable = true;
    wooting.enable = true;
  };

  services = {
    openvpn.servers.codeplay = {
      autoStart = false;
      config = ''
        script-security 2
        config /etc/nixos/secrets/codeplay.ovpn
        up ${pkgs.unstable.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
        up-restart
        down ${pkgs.unstable.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
        down-pre
      '';
    };
    xserver = {
      screenSection = ''
        Option "AllowIndirectGLXProtocol" "off"
        Option "TripleBuffer" "on"
      '';
      videoDrivers = [ "nvidiaBeta" ];
    };
  };

  # Disable `systemd-udev-settle` - it's required and just adds 1s to boot time.
  # See nixpkgs#25311.
  systemd.services.systemd-udev-settle.serviceConfig.ExecStart = [
    ""
    "${pkgs.coreutils}/bin/true"
  ];

  networking = {
    hostName = "dtw-jar-keurog";
    # `enp46s0` isn't available as it is used for GPU passthrough.
    interfaces.enp36s0.useDHCP = true;
    wireless.enable = true;
  };

  veritas = {
    profiles.virtualisation = {
      enable = true;
      virtualbox.enable = true;
    };
    david = {
      colourScheme.i3 = {
        highlight = config.veritas.david.colourScheme.basic.yellow;
        highlightBright = config.veritas.david.colourScheme.basic.brightYellow;
      };
      dotfiles = {
        autorandrProfile = {
          fingerprint = {
            "DP-2" = "00ffffffffffff001e6d077749dc0400061c0104b53c22789f3e31ae5047ac270c50542108007140818081c0a9c0d1c08100010101014dd000a0f0703e803020650c58542100001a286800a0f0703e800890650c58542100001a000000fd00283d878738010a202020202020000000fc004c472048445220344b0a20202001e60203197144900403012309070783010000e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
            "DP-0" = "00ffffffffffff001e6d077742dc0400061c0104b53c22789f3e31ae5047ac270c50542108007140818081c0a9c0d1c08100010101014dd000a0f0703e803020650c58542100001a286800a0f0703e800890650c58542100001a000000fd00283d878738010a202020202020000000fc004c472048445220344b0a20202001ed0203197144900403012309070783010000e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
          };
          config = {
            "DP-0" = {
              dpi = 163;
              enable = true;
              mode = "3840x2160";
              position = "3840x0";
              rate = "60.00";
            };
            "DP-2" = {
              dpi = 163;
              enable = true;
              mode = "3840x2160";
              position = "0x0";
              primary = true;
              rate = "60.00";
            };
          };
        };
        headless = false;
        nvidiaSettings = {
          "AllowGSYNCCompatible" = "On";
          # See nixpkgs#34977.
          "ForceFullCompositionPipeline" = "On";
        };
        uiScale = 1.5;
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
