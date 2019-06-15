{ config, pkgs, ... }:

{
  # Packages {{{
  # ========
  # Avoid installing anything like headers or packages that are specific to a project.
  environment.systemPackages = with pkgs; [
    # Development environment
    tmate universal-ctags ripgrep silver-searcher neovim tmate gist

    # Version control
    mercurial bazaar subversion git-lfs gitAndTools.hub

    # GnuPG
    paperkey libdmtx dmtx-utils
  ];
  # }}}

  # Programs {{{
  # ========
  programs = {
    # Cache compilation.
    ccache.enable = true;

    # Syntax highlight within nano.
    nano.syntaxHighlight = true;
  };
  # }}}

  # Virtualization {{{
  # ==============
  # Use libvirtd to manage virtual machines.
  virtualisation.libvirtd.enable = true;

  # Enable docker.
  virtualisation.docker = {
    autoPrune = {
      dates = "weekly";
      enable = true;
    };
    enable = true;
  };

  # Enable lxc and lxd.
  virtualisation.lxc = {
    enable = true;
    lxcfs.enable = true;
  };
  virtualisation.lxd.enable = true;
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
