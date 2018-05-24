{ config, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

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
      # Include the users to create/configure.
      ./services/users.nix
    ];

}
