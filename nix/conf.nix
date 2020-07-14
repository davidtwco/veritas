# Shared configuration options for `nix.conf` between NixOS and non-NixOS.

{
  binaryCaches = [
    "https://cachix.cachix.org"
    "https://veritas.cachix.org"
    "https://srid.cachix.org"
    "https://pre-commit-hooks.cachix.org"
  ];

  binaryCachePublicKeys = [
    "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
    "veritas.cachix.org-1:jEZ72TVmLDF3j3L8vG7llByY/cSErbL87sVGuHra9xI="
    "srid.cachix.org-1:MTQ6ksbfz3LBMmjyPh0PLmos+1x+CdtJxA/J2W+PQxI="
    "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
