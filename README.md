# Deprecation Notice
This repository is no longer used - dotfiles are now managed by chezmoi in the
[`davidtwco/dotfiles`][dotfiles] repository and my personal website redirects to my GitHub profile.

[dotfiles]: https://github.com/davidtwco/dotfiles

---

# Veritas
Veritas is the declarative configuration of my servers, desktops and laptops. This project is based
on the NixOS operating system and uses home-manager to manage my dotfiles, for both NixOS and
non-NixOS hosts (like WSL or macOS).

## Why Nix?
Nix is a powerful package manager for Linux and other Unix systems that makes package management
reliable and reproducible. It provides atomic upgrades and rollbacks, side-by-side installation of
multiple versions of a package, multi-user package management and easy setup of build environments.

## Why NixOS?
NixOS is a Linux distribution with a unique approach to package and configuration management. Built
on top of the Nix package manager, it is completely declarative, makes upgrading systems reliable,
and [has many other advantages](https://nixos.org/nixos/about.html).

# Author
This project is developed by [David Wood](https://davidtw.co).

# License
Veritas is distributed under the terms of both the MIT license and the Apache License (Version 2.0).

See [LICENSE-APACHE](LICENSE-APACHE) and [LICENSE-MIT](LICENSE-MIT) for details.
