self: super:

# This file contains a custom Nix overlay with miscellaneous packages.

{
  # Enable hybrid driver on `vaapiIntel`.
  vaapiIntel = super.vaapiIntel.override {
    enableHybridCodec = true;
  };

  # Fetch lorri from GitHub.
  lorri = import (
    super.fetchFromGitHub {
      owner = "target";
      repo = "lorri";
      rev = "03f10395943449b1fc5026d3386ab8c94c520ee3";
      sha256 = "0fcl79ndaziwd8d74mk1lsijz34p2inn64b4b4am3wsyk184brzq";
    }
  ) {};

  # Fetch niv from GitHub.
  niv = let
    src = super.fetchFromGitHub {
      owner = "nmattia";
      repo = "niv";
      rev = "064c17dc003c43d388ee36160182cc84e0f08ae1";
      sha256 = "0k89liza0jwj6rrjkvxhl21xsswcc3m5flcx8q8h4i0vbyy0yba6";
    };
  in
    (import src {}).niv;

  # Add a package for Workman.
  workman = super.callPackage ../packages/workman.nix {};

  # Add a package for rustfilt.
  rustfilt = super.callPackage ../packages/rustfilt.nix {};

  # Fetch ormolu from GitHub.
  ormolu = let
    src =
      super.fetchFromGitHub {
        owner = "tweag";
        repo = "ormolu";
        rev = "0.0.1.0";
        sha256 = "0vqrb12bsp1dczff3i5pajzhjwz035rxg8vznrgj5p6j7mb2vcnd";
      };
  in
    (import src {}).ormolu;

  pypi2nix = let
    src = builtins.fetchGit {
      url = "https://github.com/nix-community/pypi2nix.git";
      ref = "master";
      rev = "b27dc306db167e4c5ff06ff90ed825b0f35c51a1";
    };
  in
    (import src {});
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
