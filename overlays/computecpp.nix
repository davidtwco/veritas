self: super:

# This file contains a custom Nix overlay with ComputeCpp.

{
  # Add a package for ComputeCpp.
  computecpp-unwrapped = super.callPackage ../packages/computecpp.nix { };
  computecpp = let
    ccWrapperFork = import (super.fetchFromGitHub {
      owner = "davidtwco";
      repo = "nixpkgs";
      # `cc-wrapper/alternate-compilers` branch.
      rev = "a5e11fa6bcd8ed15fa9abe41e07898894bf8d1a4";
      sha256 = "1ppn821x81h5g148k4rmgvp1s8mzfakfrxypj8jiiaq0a8yrh2by";
    }) { };
  in ccWrapperFork.wrapCCWith {
    cc = self.computecpp-unwrapped;
    extraCCs = [ "compute" "compute++" ];
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
