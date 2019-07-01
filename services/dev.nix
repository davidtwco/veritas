{ config, pkgs, ... }:

{
  # Packages {{{
  # ========
  # Avoid installing anything like headers or packages that are specific to a project.
  environment.systemPackages = with pkgs; [
    # Development environment
    tmate silver-searcher tmate gist python37Packages.pip python3Full

    # Version control
    mercurial bazaar subversion

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
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
