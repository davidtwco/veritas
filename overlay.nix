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
  intel-openclrt = super.callPackage ./packages/intel-openclrt.nix { };

  # There is no `clinfo` package upstream, despite this being the most commonly used (AFAIK) tool
  # for checking device information.
  clinfo = super.callPackage ./packages/clinfo.nix { };

  # Alternative ICD loader to `ocl-icd` that is in upstream nixpkgs.
  khronos-icd-loader = super.callPackage ./packages/khronos-icd-loader { withDebug = false; };

  # Install 'Plex Pass' version of Plex.
  plexPassRaw = super.unstable.plexRaw.overrideAttrs (old: rec {
    version = "1.16.3.1433-359b06978";
    name = "${old.pname}-${version}";
    src = super.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
      sha256 = "03pqr82kgqi6fjy7wwlkbfijbkpfpp2f9rxkw5y4aya3ab7xrzxm";
    };
  });
  plexPass = super.unstable.plex.override { plexRaw = self.plexPassRaw; };

  # Fetch lorri from GitHub.
  lorri = import (super.fetchFromGitHub {
    owner = "target";
    repo = "lorri";
    # `rolling-release` branch.
    rev = "d3e452ebc2b24ab86aec18af44c8217b2e469b2a";
    sha256 = "07yf3gl9sixh7acxayq4q8h7z4q8a66412z0r49sr69yxb7b4q89";
  }) { };

  # Fetch nixfmt from GitHub.
  nixfmt = let
    src = super.fetchFromGitHub {
      owner = "serokell";
      repo = "nixfmt";
      rev = "v0.2.1";
      sha256 = "0njgjv6syv3sk97v8kq0cb4mhgrb7nag2shsj7rphs6h5b7k9nbx";
    };
  in super.callPackage src { installOnly = true; pkgs = self; };

  # Fetch niv from GitHub.
  niv = let
    src = super.fetchFromGitHub {
      owner = "nmattia";
      repo = "niv";
      rev = "8b7b70465c130d8d7a98fba1396ad1481daee518";
      sha256 = "0fgdrxn2vzpnzr6pxaiyn5zzbd812c6f7xjjhfir0kpzamjnxwwl";
    };
  in (import src {}).niv;

  # Enable hybrid driver on `vaapiIntel`.
  vaapiIntel = super.vaapiIntel.override {
    enableHybridCodec = true;
  };

  # Add a package for ComputeCpp.
  computecpp-unwrapped = super.callPackage ./packages/computecpp.nix { };
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

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
