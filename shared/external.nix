# This file contains pinned versions of upstream channels, overlays and modules so that the same
# version is used by NixOS, nix tools and home-manager.

{
  # Upstream {{{
  # ========
  homeManager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    ref = "release-19.03";
    rev = "8def3835111f0b16850736aa210ca542fcd02af6";
  };
  homeManagerUnstable = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    ref = "master";
    rev = "761b3d0c124856433ae69c77b9c44e9b5e40e6ac";
  };
  nixosUnstable = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs-channels.git";
    ref = "nixos-unstable";
    rev = "2436c27541b2f52deea3a4c1691216a02152e729";
  };
  nixpkgsUnstable = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs.git";
    ref = "master";
    rev = "15f9bdb6489e7e55a861958a9388bf5ad3b2d2cd";
  };
  mozillaOverlay = builtins.fetchGit {
    url = "https://github.com/mozilla/nixpkgs-mozilla.git";
    ref = "master";
    rev = "b52a8b7de89b1fac49302cbaffd4caed4551515f";
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
