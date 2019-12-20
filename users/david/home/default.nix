{ config, pkgs, lib, ... }:

{
  imports = [
    ./alacritty.nix
    ./autorandr.nix
    ./bash.nix
    ./ccache.nix
    ./command-not-found.nix
    ./compton.nix
    ./direnv.nix
    ./eyaml.nix
    ./feh.nix
    ./fish.nix
    ./fonts.nix
    ./fzf.nix
    ./gdb.nix
    ./git.nix
    ./gnupg.nix
    ./gtk.nix
    ./home-manager.nix
    ./htop.nix
    ./hushlogin.nix
    ./i3.nix
    ./info.nix
    ./jq.nix
    ./keybase.nix
    ./language.nix
    ./less.nix
    ./lorri.nix
    ./mail.nix
    ./manpages.nix
    ./neovim.nix
    ./packages.nix
    ./polybar.nix
    ./qt.nix
    ./readline.nix
    ./redshift.nix
    ./rofi.nix
    ./scripts.nix
    ./ssh.nix
    ./starship.nix
    ./systemd.nix
    ./tmux.nix
    ./xdg.nix
    ./xresources.nix
    ./xsession.nix
  ];

  # This configuration only applies to home-manager, not NixOS or nix-shell.
  nixpkgs = {
    config = import ../../../nix/config.nix;
    overlays = let
      sources = import ../../../nix/sources.nix;
      unstable = import sources.nixpkgs { config = config.nixpkgs.config; };
    in
      [
        (_: _: { inherit unstable; })
        (import sources.nixpkgs-mozilla)
        (
          _: super: {
            niv = (import sources.niv {}).niv;
            lorri = import sources.lorri {};
            ormolu = (import sources.ormolu {}).ormolu;
            pypi2nix = import sources.pypi2nix {};
            rustfilt = super.callPackage ../../../packages/rustfilt.nix {};
            workman = super.callPackage ../../../packages/workman.nix {};
          }
        )
      ];
  };

  xdg.configFile."nixpkgs/config.nix".source = ../../../nix/config.nix;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
