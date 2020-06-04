{ pkgs ? import <nixpkgs> { } }:

# This file contains a development shell for working on LLVM and Clang which contains only the
# required tools for building/running/testing LLVM and Clang.
#
# `buildFHSUserEnv` is used instead of `mkShell` so that the headers expected by an unwrapped
# clang can be found in the expected location.
let
  common = import ./common.nix { inherit pkgs; };
in
(
  pkgs.buildFHSUserEnv {
    name = "llvm";

    # `targetPkgs` contains packages to be installed for the main host's architecture.
    targetPkgs = pkgs: (common.targetPkgs pkgs);

    # `multiPkgs` contains packages to be installed for the all architecture's supported by the host.
    multiPkgs = pkgs: (common.multiPkgs pkgs);

    # `profile` can be used to set environment variables.
    profile = common.profile;

    # `runScript` determines the command that runs when the shell is entered.
    runScript = "bash --norc";
  }
).env

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
