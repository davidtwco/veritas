{ stdenv, lib, fetchFromGitHub, rustPlatform, darwin, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "measureme";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = pname;
    rev = version;
    hash = "sha256-OzH3+SgdOr+tkChh3ExHOps+ksFa00wS/VmTSflKofM=";
  };

  cargoPatches = [ ./0001-add-cargo-lock.patch ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = (lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security) ++ [
    openssl
  ];

  cargoSha256 = "sha256:A2Dm4xJyAJjKCcB+d0gJFKvJpT0yFwFzU8RlL2FjH8o=";

  meta = with lib; {
    description = "Tools for working with rustc's self-profiling feature";
    homepage = "https://github.com/rust-lang/${pname}";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
