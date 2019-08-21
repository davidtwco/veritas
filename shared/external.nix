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
    rev = "3d84cffe95527abf139bd157befab677ba04a421";
  };
  mozillaOverlay = builtins.fetchGit {
    url = "https://github.com/mozilla/nixpkgs-mozilla.git";
    ref = "master";
    rev = "200cf0640fd8fdff0e1a342db98c9e31e6f13cd7";
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
