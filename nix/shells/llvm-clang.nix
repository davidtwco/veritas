{ pkgs ? import <nixpkgs> { } }:

# This file contains a development shell for working on LLVM and Clang which contains only the
# required tools for building/running/testing LLVM and Clang.
#
# `buildFHSUserEnv` is used instead of `mkShell` so that the headers expected by an unwrapped
# clang can be found in the expected location.
let
  # Combine the `lib` and `out` outputs of the `cudatoolkit_10` package to re-produce
  # what the original CUDA toolkit package would contain and is expected to have.
  cuda-toolkit-joined = pkgs.symlinkJoin {
    name = "cudatoolkit_10_joined";
    paths = with pkgs; [ cudatoolkit_10.out cudatoolkit_10.lib ];
  };

  # Join C++ and C headers for OpenCL headers.
  opencl-c-and-cpp-headers = pkgs.symlinkJoin {
    name = "opencl-c-and-cpp-headers";
    paths = with pkgs; [ opencl-headers opencl-clhpp ];
  };

  # Join gcc8 (wrapped) and gcc8 (unwrapped) so that we get the C++ standard library headers
  # from the unwrapped package but the wrapped binary from the wrapped package.
  gcc8-joined = pkgs.symlinkJoin {
    name = "gcc8-joined";
    paths = with pkgs; [ gcc8 gcc8.cc ];
  };

  # Define a python package with pygments, psutil and PyYAML.
  python3WithExtraPackages =
    pkgs.python37Full.withPackages (pkgs: with pkgs; [ psutil pygments pyyaml ]);

  fhsUserEnv = pkgs.buildFHSUserEnv {
    name = "llvm-clang";

    # `targetPkgs` contains packages to be installed for the main host's architecture.
    targetPkgs = pkgs: (
      with pkgs; [
        # Build system used by LLVM.
        cmake
        # Compiler cache - speeds up compilation.
        ccache
        # GNU Make and Ninja - generators for CMake.
        gnumake
        ninja
        # pkg-config - used by CMake to find things.
        pkg-config

        # C/C++ compiler for building Clang/LLVM.
        gcc8-joined
        libgcc
        glibc.dev
        # binutils - required for building
        binutils

        # Git - useful if committing from the FHS environment and is looked for by CMake.
        git
        openssh
        # Python - required by LLVM's CMake.
        python3WithExtraPackages
        # libxml2 - looked for by CMake.
        libxml2.dev
        # ncurses6 - looked for by CMake.
        ncurses6.dev
        # zlib - looked for by CMake.
        zlib.dev

        # OpenCL headers - required by libclc.
        opencl-c-and-cpp-headers
        # OpenCL ICD loader - provides `libOpenCL.so.1`.
        ocl-icd
        # Intel's OpenCL runtime.
        intel-openclrt
        intel-compute-runtime
        # clinfo - query available OpenCL devices.
        clinfo

        # NVIDIA's OpenCL runtime and `libdevice.so` (for NVPTX backend).
        cuda-toolkit-joined
        linuxPackages.nvidia_x11
        # NVIDIA/CUDA dependencies.
        xorg.libXi
        xorg.libXmu
        xorg.libXext
        xorg.libX11
        xorg.libXv
        xorg.libXrandr
        libGLU
        procps
        freeglut
        jansson

        # SPIRV-Tools - looked for by CMake. Provides `spirv-val` and `spirv-as`.
        spirv-tools

        # Required to stop shell mangling on tab completion.
        glibcLocales

        # Required for nested shells in lorri to work correctly.
        bashInteractive
      ]
    );

    # `multiPkgs` contains packages to be installed for the all architecture's supported by the host.
    multiPkgs = pkgs: (with pkgs; [ ]);

    profile = ''
      # Use icd files from the chroot.
      export OCL_ICD_VENDORS=/etc/OpenCL/vendors

      # Declare variables to OCL library and headers.
      export OCL_LIBRARY=${pkgs.ocl-icd}/lib/libOpenCL.so.1
      export OCL_INCLUDE_DIR=${opencl-c-and-cpp-headers}/include

      # Default to using Ninja.
      export CMAKE_GENERATOR=Ninja

      # Set locale variables.
      export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
      export LANG=en_GB.utf8
      export LANGUAGE=en_GB.utf8
      export LC_ALL=en_GB.utf8
    '';

    # `runScript` determines the command that runs when the shell is entered.
    runScript = "bash";
  };
in
fhsUserEnv.env

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
