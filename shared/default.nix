{ config, pkgs, ... }:

# This file contains a shared configuration of `nixpkgs.*` that is used by both home-manager and
# NixOS.

let
  external = import ./external.nix;
in {
  # `nixpkgs.overlays` is the canonical list of overlays used in the system. Overlays that are
  # merged into `nixpkgs.overlays` from other files (such as the qemu aarch64 module) won't be
  # available in home-manager.
  #
  # From the NixOS documentation:
  #
  # > The first argument (self) corresponds to the final package set. You should use this set
  # > for the dependencies of all packages specified in your overlay. For example, all the
  # > dependencies of rr in the example above come from self, as well as the overridden
  # > dependencies used in the boost override.
  # >
  # > The second argument (super) corresponds to the result of the evaluation of the previous
  # > stages of Nixpkgs. It does not contain any of the packages added by the current overlay,
  # > nor any of the following overlays. This set should be used either to refer to packages you
  # > wish to override, or to access functions defined in Nixpkgs. For example, the original
  # > recipe of boost in the above example, comes from super, as well as the callPackage function.
  nixpkgs.overlays = let
    unstable = import external.nixpkgsUnstable { config = config.nixpkgs.config; };
  in [
    # Define a simple overlay that roots the unstable channel at `pkgs.unstable`.
    (self: super: { inherit unstable; })
    # Add our own overlays.
    (import ../overlays/computecpp.nix)
    (import ../overlays/opencl.nix)
    (import ../overlays/packages.nix)
    (import ../overlays/plex.nix)
    # Use Mozilla's overlay for `rustChannelOf` function.
    (import external.mozillaOverlay)
  ];

  nixpkgs.config = import ./config.nix;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
