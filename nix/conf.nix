# Shared configuration options for `nix.conf` between NixOS and non-NixOS.

{
  binaryCaches = [
    "https://cachix.cachix.org"
    "https://srid.cachix.org"
  ];

  binaryCachePublicKeys = [
    "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
    "srid.cachix.org-1:MTQ6ksbfz3LBMmjyPh0PLmos+1x+CdtJxA/J2W+PQxI="
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
