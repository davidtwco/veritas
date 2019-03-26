{ config, pkgs, ... }:

{
  # Packages {{{
  # ========
  environment.systemPackages = with pkgs; [
    # C/C++
    valgrind gdb rr llvmPackages.libclang patchelf ccache gcc cmake llvm gnumake autoconf nasm
    automake ninja libcxxabi libcxx clang-tools cquery clang clang_7 spirv-tools opencl-headers
    opencl-info ocl-icd

    # CI
    travis

    # Development environment
    vim tmux ctags alacritty rustup ripgrep silver-searcher neovim tmate

    # Documentation
    git-latexdiff proselint pandoc doxygen

    # Graphviz
    graphviz python36Packages.xdot

    # Node.js
    nodejs

    # Python
    pipenv pypy pythonFull python2Full python3Full python27Packages.virtualenv
    python36Packages.virtualenv

    # Ruby
    jekyll ruby rubocop

    # Version control
    git gnupg mercurial bazaar subversion git-lfs
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
  virtualisation.docker.enable = true;
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
