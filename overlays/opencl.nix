self: super:

# This file contains a custom Nix overlay with OpenCL packages.

{
  # Updated version of the Intel OpenCL Runtime that supports more recent versions of OpenCL.
  intel-openclrt = super.callPackage ../packages/intel-openclrt.nix {};

  # Alternative ICD loader to `ocl-icd` that is in upstream nixpkgs.
  khronos-icd-loader = super.callPackage ../packages/khronos-icd-loader { withDebug = false; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
