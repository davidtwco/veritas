# Veritas
Veritas is the declarative configuration of my servers, desktops and laptops. This project is based
on the NixOS operating system and uses home-manager to manage my dotfiles, for both NixOS and
non-NixOS hosts (like WSL).

## Why Nix?
Nix is a powerful package manager for Linux and other Unix systems that makes package management
reliable and reproducible. It provides atomic upgrades and rollbacks, side-by-side installation of
multiple versions of a package, multi-user package management and easy setup of build environments.

## Why NixOS?
NixOS is a Linux distribution with a unique approach to package and configuration management. Built
on top of the Nix package manager, it is completely declarative, makes upgrading systems reliable,
and [has many other advantages](https://nixos.org/nixos/about.html).

# Usage
This project has been built to support both NixOS and non-NixOS systems. On either type of system,
remember to import the GPG public key.

## NixOS
On NixOS systems, install NixOS with a basic configuration and copy the resulting
`hardware-configuration.nix` and `configuration.nix` contents into a clone of this repository at
`/etc/nixos/hosts/<name>.nix`, removing any duplication of configuration already handled by the
repository. Symlink that file to `/etc/nixos/configuration.nix` before running `nixos-rebuild`.

## Non-NixOS
On non-NixOS systems, Veritas can be used to manage the dotfiles of a system:

1. Install Nix by following the [Nix manual's installation instructions][nixos_install].
2. Install home-manager by following the first two steps of the
   [home-manager installation instructions][home-manager_install] (at the time of writing, this
   adds the home-manager channel).
3. Clone this repository to `~/.config/nixpkgs`.
4. Write a new file for this system at `~/.config/nixpkgs/hosts/<name>.nix` with the following
   contents:

`~/.config/nixpkgs/home.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  # Import the main home-manager configuration.
  imports = [ ../users/david/home ];

  # Add the `veritas.david` configuration options. These are also used from NixOS.
  options.veritas.david = import ../users/david/options.nix { inherit config; inherit lib; };
  # Optionally, change configuration options specific to this deployment of Veritas.
  config.veritas.david = {
    dotfiles.headless = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
```

5. Symlink that file to `~/.config/nixpkgs/home.nix`.
6. Run `nix-shell '<home-manager>' -A install` and `home-manager switch` thereafter.

[nixos_install]: https://nixos.org/nix/manual/#chap-installation
[home-manager_install]: https://github.com/rycee/home-manager#installation

### WSL 1
On WSL 1, the following must be added to `~/.config/nix/nix.conf` for home-manager to work
correctly:

```
sandbox = false
use-sqlite-wal = false
```

Set `veritas.david.dotfiles.isWsl` to `true`.

### WSL 2
Currently, on WSL 2, the sockets forwarding from Windows used by the GPG and SSH agents don't
work, so WSL 1 has to be used. Set `veritas.david.dotfiles.isWsl` to `true`.

# Structure
The structure of this repository is described below:

Path                       | Description
----                       | -----------
`/hosts`                   | top-level expressions specific to individual workstations or servers
`/overlay.nix`             | package overrides used throughout the configuration
`/packages`                | custom packages
`/profiles`                | common configurations shared between hosts
`/modules`                 | re-usable configuration modules
`/shared/compat.nix`       | compatibility overlay to allow nix tools to use NixOS overlays
`/shared/config.nix`       | `nixpkgs.config.*` configuration, shared between home-manager and NixOS
`/shared/default.nix`      | `nixpkgs.*` configuration, shared between home-manager and NixOS
`/shared/external.nix`     | expression containing pinned commits of upstream repositories
`/users/david/default.nix` | module that creates `david` user and instantiates home-manager config
`/users/david/options.nix` | `veritas.david` module options, shared between home-manager and NixOS
`/users/david/home`        | home-manager configuration

# Author
This project is developed by [David Wood](https://davidtw.co).

# License
Veritas is distributed under the terms of both the MIT license and the Apache License (Version 2.0).

See [LICENSE-APACHE](LICENSE-APACHE) and [LICENSE-MIT](LICENSE-MIT) for details.
