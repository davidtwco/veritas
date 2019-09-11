# This file contains pinned versions of upstream channels, overlays and modules so that the same
# version is used by NixOS, nix tools and home-manager.

{
  # Upstream {{{
  # ========
  homeManager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    ref = "release-19.03";
    rev = "45a73067ac6b5d45e4b928c53ad203b80581b27d";
  };
  homeManagerUnstable = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    ref = "master";
    rev = "6932e6330e9cbe73629e9f15300bdd0d3b9cc418";
  };
  nixpkgsUnstable = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs-channels.git";
    ref = "nixos-unstable";
    rev = "e19054ab3cd5b7cc9a01d0efc71c8fe310541065";
  };
  mozillaOverlay = builtins.fetchGit {
    url = "https://github.com/mozilla/nixpkgs-mozilla.git";
    ref = "master";
    rev = "200cf0640fd8fdff0e1a342db98c9e31e6f13cd7";
  };
  dwarffs = builtins.fetchGit {
    url = "https://github.com/edolstra/dwarffs.git";
    ref = "master";
    rev = "531a2338101f0b6db2d9d512c3f98145f7b75397";
  };
  qemuAarch64 = builtins.fetchGit {
    url = "https://github.com/cleverca22/nixos-configs.git";
    ref = "master";
    rev = "76260ad60cd99d40ab25df1400b0663d48e736db";
  };
  # }}}

  # Forks {{{
  # =====
  homeManagerSshForwardsFork = builtins.fetchGit {
    url = "https://github.com/davidtwco/home-manager.git";
    ref = "internal/ssh/remote-dynamic-forwards";
    rev = "94d668c03a6eb76fe84f17cc179a7179ed4c9422";
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
