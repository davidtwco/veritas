self: super:

# This file contains a custom Nix overlay with ComputeCpp.

{
  # Add a package for ComputeCpp.
  computecpp-unwrapped = super.callPackage ../packages/computecpp.nix {};
  computecpp = super.unstable.wrapCCWith {
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
