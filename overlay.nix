self: super:

# This file contains a custom Nix overlay, each top-level attribute defines a custom package.
#
# From the NixOS documentation:
#
# > The first argument (self) corresponds to the final package set. You should use this set
# > for the dependencies of all packages specified in your overlay. For example, all the
# > dependencies of rr in the example above come from self, as well as the overridden dependencies
# > used in the boost override.
# >
# > The second argument (super) corresponds to the result of the evaluation of the previous stages
# > of Nixpkgs. It does not contain any of the packages added by the current overlay, nor any of
# > the following overlays. This set should be used either to refer to packages you wish to
# > override, or to access functions defined in Nixpkgs. For example, the original recipe of
# > boost in the above example, comes from super, as well as the callPackage function.

{
  # Updated version of the Intel OpenCL Runtime that supports more recent versions of OpenCL.
  intel-ocl = super.callPackage ./packages/intel-ocl.nix {
    # Unfortunately, due to the hardware on dtw-volkov, linking with `libnuma` will cause
    # `clCreateContext` to fail.
    withNuma = false;
  };

  # There is no `clinfo` package upstream, despite this being the most commonly used (AFAIK) tool
  # for checking device information.
  clinfo = super.callPackage ./packages/clinfo.nix { };

  # Alternative ICD loader to `ocl-icd` that is in upstream nixpkgs.
  khronos-icd-loader = super.callPackage ./packages/khronos-icd-loader/default.nix {
    withDebug = false;
  };

  # Upgrade franz to the most recent version.
  franz = super.franz.overrideDerivation (old: {
    name = "franz-5.1.0";
    src = self.fetchurl {
      url = "https://github.com/meetfranz/franz/releases/download/v5.1.0/franz_5.1.0_amd64.deb";
      sha256 = "a474d2e9c6fb99abfc4c7e9290a0e52eef62233fa25c962afdde75fe151277d0";
    };
  });

  # CUDA puts `cicc` in a folder other than `/bin` so the upstream derivation doesn't put it in the
  # `$out/bin` folder.
  cudatoolkit_10 = super.cudatoolkit_10.overrideDerivation(old: {
    postInstall = ''
      install -D -m0755 $out/nvvm/bin/cicc -t $out/bin
    '';
  });
}
