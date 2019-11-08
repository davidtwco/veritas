self: super:

# This file contains a custom Nix overlay with OpenCL packages.

{
  # Updated version of the Intel OpenCL Runtime that supports more recent versions of OpenCL.
  intel-openclrt = super.callPackage ../packages/intel-openclrt.nix {};
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
