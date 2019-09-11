{ pkgs ? import <nixpkgs> {} }:

# This file contains a development shell for working on LLVM/Clang.

let
  # Pin version of davidtwco's configuration that is used for extra packages.
  veritasRepo = builtins.fetchGit {
    url = "https://github.com/davidtwco/veritas.git";
    ref = "master";
    rev = "a3adcaa5092d7ee97da7ed04dda7cfcb1c14daa3";
  };
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
  # Pull clinfo and the latest version of the Intel OpenCL runtime from davidtwco's configuration.
  clinfo = pkgs.callPackage "${veritasRepo}/packages/clinfo.nix" { };
  intel-openclrt = pkgs.callPackage "${veritasRepo}/packages/intel-openclrt.nix" { };
  # Define a python package with pygments and PyYAML.
  python3WithExtraPackages =
    pkgs.python37Full.withPackages (pkgs: with pkgs; [ psutil pygments pyyaml ]);
# `buildFHSUserEnv` is used instead of `mkShell` so that the headers expected by an unwrapped
# clang can be found in the correct place.
in (pkgs.buildFHSUserEnv {
  name = "llvm";
  # `targetPkgs` contains packages to be installed for the main host's architecture.
  targetPkgs = pkgs: (with pkgs; [
    # Build system used by LLVM.
    cmake
    # Compiler cache - speeds up compilation.
    ccache
    # GNU Make and Ninja - generators for CMake.
    gnumake ninja
    # pkg-config - used by CMake to find things.
    pkg-config

    # C/C++ compiler for building Clang/LLVM.
    gcc8-joined libgcc glibc.dev
    # binutils - required for building
    binutils

    # Git - useful if committing from the FHS environment and is looked for by CMake.
    git openssh
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
    # clinfo - query available OpenCL devices.
    clinfo

    # NVIDIA's OpenCL runtime and `libdevice.so` (for NVPTX backend).
    cuda-toolkit-joined linuxPackages.nvidia_x11
    # NVIDIA/CUDA dependencies.
    xorg.libXi xorg.libXmu xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr
    libGLU_combined procps freeglut jansson

    # SPIRV-Tools - looked for by CMake. Provides `spirv-val` and `spirv-as`.
    spirv-tools
  ]);
  # `multiPkgs` contains packages to be installed for the all architecture's supported by the host.
  multiPkgs = pkgs: (with pkgs; []);
  # `profile` can be used to set environment variables.
  profile = ''
    # Use icd files from the chroot.
    export OCL_ICD_VENDORS=/etc/OpenCL/vendors

    # Declare variables to OCL library and headers.
    export OCL_LIBRARY=${pkgs.ocl-icd}/lib/libOpenCL.so.1
    export OCL_INCLUDE_DIR=${opencl-c-and-cpp-headers}/include

    # Unset any language variables that are set by the parent environment.
    export LC_ALL=
    export LANGUAGE=
    export LANG=
  '';
  # `runScript` determine the command that runs when the shell is entered.
  runScript = "bash --norc";
}).env
