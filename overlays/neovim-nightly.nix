self: super:

# This file contains a custom Nix overlay with a nightly version of Neovim (unreleased,
# containing termdebug).

{
  neovim-nightly-unwrapped = let
    # Use a fork which fixes NixOS/nixpkgs#64400.
    nightlyNeovimFork = import (super.fetchFromGitHub {
      owner = "gloaming";
      repo = "nixpkgs";
      # `feature/nightly-neovim` branch.
      rev = "930254677c19e628ec2ab0033758cf67e0944925";
      sha256 = "042riy1xlgmffnmyvp905zfi0i8sjiq9dpdbn47w76jpzkp2yg6q";
    }) { };
  in nightlyNeovimFork.neovim-unwrapped.overrideAttrs (old: rec {
    # Upgrade forked version to a newer nightly.
    version = "nightly-82d52b2";
    name = "neovim-unwrapped-${version}";
    src = super.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "82d52b229df711b710862ce772603ea55113a32e";
      sha256 = "0va09his9j793ygm7qfhf0v20g2xlby2c74ixzcm7c2bnqm8r7qc";
    };
  });
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
