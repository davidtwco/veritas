# This file contains a development shell for working on the Rust reference.
let
  # Import unstable channel for newer versions of packages.
  sources = import ../nix/sources.nix;
  unstable = import sources.nixpkgs-unstable {
    overlays = [ (import sources.nixpkgs-mozilla) ];
  };
in
unstable.mkShell {
  name = "rust-reference";
  buildInputs = with unstable; [
    mdbook
    (rustChannelOf { date = "2019-10-26"; channel = "nightly"; }).rust
    python
  ];
}
