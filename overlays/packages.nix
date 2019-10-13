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

  # Add a package for mdcat.
  mdcat = super.unstable.callPackage ../packages/mdcat.nix {
    inherit (super.darwin.apple_sdk.frameworks) Security;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
