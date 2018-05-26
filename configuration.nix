{ config, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

  # Automatically optimise the Nix store.
  nix.autoOptimiseStore = true;

  # Import various configurations for the system.
  imports =
    [
      # Include the results of the hardware scan and host-specific configurations.
      # Symlink these from the correct host in the `hosts/` folder.
      ./hardware-configuration.nix
      ./host-configuration.nix
      # Include the wireless network configurations.
      ./secrets/wifi.nix
      # Include the internationalisation configuration.
      ./services/i18n.nix
      # Include the packages to install.
      ./services/packages.nix
      # Include the X server and window manager configuration.
      ./services/x.nix
      # Include configuration for audio.
      ./services/audio.nix
      # Include configuration for bluetooth.
      ./services/bluetooth.nix
      # Include configuration for networking.
      ./services/networking.nix
      # Include the users to create/configure.
      ./services/users.nix
    ];
}
