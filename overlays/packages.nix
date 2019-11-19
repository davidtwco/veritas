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
      rev = "d05f00a84f887b042c8feceb2c29bbdec438c9e6";
      sha256 = "1rhykd65a6zh4ak3z0hz0hbg91ifc6q7lcfyqhdd8w72ywsx3kaw";
    }
  ) {};

  # Fetch niv from GitHub.
  niv = let
    src = super.fetchFromGitHub {
      owner = "nmattia";
      repo = "niv";
      rev = "1dd094156b249586b66c16200ecfd365c7428dc0";
      sha256 = "1b2vjnn8iac5iiqszjc2v1s1ygh0yri998c0k3s4x4kn0dsqik21";
    };
  in
    (import src {}).niv;

  # Add a package for Workman.
  workman = super.callPackage ../packages/workman.nix {};

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
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
