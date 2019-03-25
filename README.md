# nixfiles
[![license][license-badge]][license]
[![nixos][nix-badge]][nix]
[![say thanks][st-badge]][st]

NixOS configuration files for my reproducible system configuration.

[license]: https://github.com/davidtwco/nixfiles
[license-badge]: https://img.shields.io/github/license/davidtwco/nixfiles.svg?style=flat-square
[nix]: https://nixos.org
[nix-badge]: https://img.shields.io/badge/powered%20by-NixOS-blue.svg?style=flat-square
[st]: https://saythanks.io/to/davidtwco
[st-badge]: https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg?style=flat-square

# How do I use this?
To use, follow the below steps:

1. Clone this to `/etc/nixos` (you may need to temporarily add `git` to the default Nix configuration).
2. Symlink the `.nix` file for the host in the `hosts/` directory to `/etc/nixos/configuration.nix`.
3. Run `sudo nix-rebuild switch`.
