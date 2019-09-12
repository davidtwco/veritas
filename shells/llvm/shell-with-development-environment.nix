{ pkgs ? import <nixpkgs> {} }:

# This file contains a development shell for working on LLVM and Clang which includes impure
# additions that allow using the same development environment and tools as a regular impure
# nix-shell would (not a FHS environment).
#
# `buildFHSUserEnv` is used instead of `mkShell` so that the headers expected by an unwrapped
# clang can be found in the expected location.

let
  common = import ./common.nix { inherit pkgs; };
in (pkgs.buildFHSUserEnv {
  name = "llvm-dev";
  # `targetPkgs` contains packages to be installed for the main host's architecture.
  targetPkgs = pkgs: (common.targetPkgs pkgs) ++ (with pkgs; [ zsh ]);
  # `multiPkgs` contains packages to be installed for the all architecture's supported by the host.
  multiPkgs = pkgs: (common.multiPkgs pkgs);
  # `profile` can be used to set environment variables.
  profile = common.profile + ''
    # Add nix-profile to the PATH.
    export PATH=$PATH:$HOME/.nix-profile/bin
  '';
  # `runScript` determines the command that runs when the shell is entered.
  runScript = "zsh";
}).env
