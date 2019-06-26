{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 8;

  imports = [ ../common.nix ];

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      luks.devices = [
        {
          name = "root";
          device = "/dev/nvme0n1p2";
          preLVM = true;
        }
      ];
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "nomodeset" "video=vesa:off" "vga=normal" ];
    vesa = false;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/15e4642b-713f-4e33-bb57-bccba586ca9d";
      fsType = "btrfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/54D5-DC0D";
      fsType = "vfat";
    };
    "/data" = {
      device = "/dev/disk/by-uuid/f09ffaad-ce2e-479d-857c-7cd1605c51d3";
      fsType = "btrfs";
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  networking = {
    hostName = "dtw-volkov";
    interfaces.eno1.useDHCP = true;
    wireless.enable = false;
  };

  veritas = {
    hardware.wooting.enable = true;
    profiles.virtualisation.enable = true;
    david = {
      # Set the email address that should be used by the dotfiles in configuration files
      # (eg. `.gitconfig`).
      email.address = "david.wood@codeplay.com";
      dotfiles = {
        autorandrProfile = {
          fingerprint = {
            "DP-0" = "00ffffffffffff0010ac6fd04c33413015190104a5371f783e4455a9554d9d260f5054a54b00b300d100714fa9408180778001010101565e00a0a0a029503020350029372100001a000000ff0039583256593535493041334c0a000000fc0044454c4c205532353135480a20000000fd0038561e711e010a20202020202001a402031cf14f1005040302071601141f12132021222309070783010000023a801871382d40582c450029372100001e011d8018711c1620582c250029372100009e011d007251d01e206e28550029372100001e8c0ad08a20e02d10103e9600293721000018483f00ca808030401a50130029372100001e00000000000000000057";
            "HDMI-0" = "00ffffffffffff0010ac70d04c4639301519010380371f78ee4455a9554d9d260f5054a54b00b300d100714fa9408180778001010101565e00a0a0a029503020350029372100001a000000ff0039583256593535493039464c0a000000fc0044454c4c205532353135480a20000000fd0038561e711e000a2020202020200104020322f14f1005040302071601141f1213202122230907078301000065030c001000023a801871382d40582c250029372100001e011d8018711c1620582c250029372100009e011d007251d01e206e28550029372100001e8c0ad08a20e02d10103e9600293721000018483f00ca808030401a50130029372100001e000000ed";
          };
          config = {
            "DP-0" = {
              enable = true;
              dpi = 109;
              mode = "2560x1440";
              primary = true;
              position = "0x0";
              rate = "59.95";
            };
            "HDMI-0" = {
              enable = true;
              dpi = 109;
              mode = "2560x1440";
              position = "2560x0";
              rate = "59.95";
            };
          };
        };
        headless = false;
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
