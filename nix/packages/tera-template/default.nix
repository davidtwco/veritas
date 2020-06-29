{ stdenv, gitignoreSource, rustPlatform, darwin }:

with stdenv.lib;
rustPlatform.buildRustPackage rec {
  name = "tera-template";
  src = gitignoreSource ./.;

  buildInputs = optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  cargoSha256 = "sha256-q8qrYi7IjZWSE/Pn1JoBEZlrz4qqFp5FMUb37SBP9pQ=";

  doCheck = false;

  meta = {
    description = "Template rendering utility";
    license = with licenses; [ mit asl20 ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
