# When a file is listed in $NIX_PATH, then the Nix expression is used as a list of overlays, so
# we must return a list.
let
  compat = (
    # Define a compatability overlay that will load the overlays defined in `nixpkgs.overlays`
    # from the NixOS configuration.
    self: super:

    with super.lib;
    let
      # Use NixOS plumbing to evaluate the NixOS configuration and get the `nixpkgs.overlays`
      # option.
      eval = import <nixpkgs/nixos/lib/eval-config.nix>;
      paths = (eval { modules = [ (import <nixos-config>) ]; }).config.nixpkgs.overlays;
    in
      foldl' (flip extends) (_: super) paths self
  );
in
  [ compat ]

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
