{ pkgs ? import <nixpkgs> {} }:

# This file contains a development shell for working on Zulip.

pkgs.mkShell {
  buildInputs = with pkgs; [ vagrant docker git openssh ];
}
