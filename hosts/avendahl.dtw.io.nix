{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 12;

  imports = [ ../common.nix ];

  # Boot Loader {{{
  # ===========
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = ["/dev/nvme0n1" "/dev/nvme1n1"];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  # }}}

  # Filesystems {{{
  # ===========
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9c941292-69fb-4dcd-89e3-f255712700a5";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/99b75992-0079-438c-ae96-a4edbfae52ab";
      fsType = "ext3";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/eb08dc81-dddc-4763-8a13-9b8270836df4"; }
    ];
  # }}}

  # OpenSSH {{{
  # =======
  # Change the SSH port to being port scanned all the time.
  services.openssh.ports = [ 28028 ];
  # }}}

  # Microcode {{{
  # =========
  hardware.cpu.intel.updateMicrocode = true;
  # }}}

  # Networking {{{
  # ==========
  networking = {
    hostName = "dtw-avendahl";
    useDHCP = true;
    wireless.enable = false;
  };
  # }}}

  # Veritas {{{
  # =======
  veritas.profiles = {
    simple-mail-relay.enable = true;
    virtualisation.enable = true;
  };
  # }}}

  # Workman {{{
  # =======
  systemd.services."workman-update-rust" = {
    description = "Update the working directories for Rust using workman";
    enable = true;
    environment = {
      # Ensure these are consistent with the environment used during development so CMake
      # doesn't need to reconfigure.
      "AR" = "${pkgs.binutils-unwrapped}/bin/ar";
      "CC" = "${pkgs.gcc}/bin/gcc";
      "CXX" = "${pkgs.gcc}/bin/g++";
      # If `SSH_AUTH_SOCK` isn't overriden then gpg-agent can interfere.
      "SSH_AUTH_SOCK" = "";
      # `GIT_SSH_COMMAND` needs to be set to a key w/out a passphrase.
      "GIT_SSH_COMMAND" = let
        flags = "-o StrictHostKeyChecking=no";
        identity = "${config.users.extraUsers.david.home}/.ssh/id_workman_rsa";
      in "${pkgs.openssh}/bin/ssh ${flags} -i ${identity}";
    };
    onFailure = lib.mkIf (config.veritas.profiles.simple-mail-relay.enable) [
      "systemd-unit-status-email@%n.service"
    ];
    path = with pkgs; [
      bash binutils binutils-unwrapped ccache clang cmake coreutils curl direnv gcc gdb git
      glibc gnugrep gnumake ncurses ninja nodejs openssh patchelf pythonFull rustup tmux
    ];
    reloadIfChanged = false;
    serviceConfig = {
      "ExecStart" = "${pkgs.workman}/bin/workman update";
      "RemainAfterExit" = true;
      "Type" = "simple";
      "WorkingDirectory" = "${config.users.extraUsers.david.home}/projects/rust";
      "User" = "david";
    };
    startAt = "*-*-* 2:00:00";
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
