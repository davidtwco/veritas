self: super:

# This file contains a custom Nix overlay with a nightly version of Starship (unreleased,
# containing style configuration).

{
  # Update Starship to the latest version. If named `starship`, then Nix consumes
  # all memory, which isn't fun.
  starship-nightly = super.unstable.starship.overrideAttrs (old: rec {
    version = "0.16.0";
    name = "${old.pname}-${version}";
    src = super.unstable.fetchFromGitHub {
      owner = "starship";
      repo = "starship";
      rev = "v${version}";
      sha256 = "02kfan07szci6z0f8v8qgx24rbx00ncy1ak682bwpb2zn7nb42ky";
    };
  });
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
