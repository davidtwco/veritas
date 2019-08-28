self: super:

# This file contains a custom Nix overlay with ComputeCpp.

{
  # Add a package for ComputeCpp.
  computecpp-unwrapped = super.callPackage ../packages/computecpp.nix {};
  computecpp = let
    ccWrapperFork = import (
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        # `staging` branch, post nixpkgs#65813.
        rev = "acfa5d83245ee5661c5540a2a90b4a97f35c3296";
        sha256 = "13gy4zisnrg5y0zxp4yaac7c31dlsrqhnq8n06swgykm0nfgvy7b";
      }
    ) {};
  in
    ccWrapperFork.wrapCCWith {
      cc = self.computecpp-unwrapped;
      extraBuildCommands = ''
        wrap compute $wrapper $ccPath/compute
        wrap compute++ $wrapper $ccPath/compute++
        export named_cc=compute
        export named_cxx=compute++
      '';
    };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
