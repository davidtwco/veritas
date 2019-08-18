{ config, pkgs, ... }:

# This file contains a shared configuration of `nixpkgs.*` that is used by both home-manager and
# NixOS.

let
  external = import ./external.nix;
in {
  # `nixpkgs.overlays` is the canonical list of overlays used in the system.
  nixpkgs.overlays = let
    unstable = import external.nixpkgsUnstable { config = config.nixpkgs.config; };
  in [
    # Define a simple overlay that roots the unstable channel at `pkgs.unstable`.
    (self: super: { inherit unstable; })
    # Define custom packages and overrides in `./overlay.nix`.
    (import ./overlay.nix)
    # Use Mozilla's overlay for `rustChannelOf` function.
    (import external.mozillaOverlay)
  ];

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
