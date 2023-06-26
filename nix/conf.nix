# Shared configuration options for `nix.conf` between NixOS and non-NixOS.

{
  binaryCaches = [
    "https://cachix.cachix.org"
    "https://veritas.cachix.org"
    "https://helix.cachix.org"
  ];

  binaryCachePublicKeys = [
    "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
    "veritas.cachix.org-1:jEZ72TVmLDF3j3L8vG7llByY/cSErbL87sVGuHra9xI="
    "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
  ];
}
