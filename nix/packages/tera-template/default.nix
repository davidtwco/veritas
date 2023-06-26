{ stdenv, lib, gitignoreSource, rustPlatform, darwin }:

with lib;
rustPlatform.buildRustPackage rec {
  name = "tera-template";
  src = gitignoreSource ./.;

  buildInputs = optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  cargoSha256 = "sha256-nwVAZVGqTA+I0l45RMgNW6DimqzQUqK86F1v8spT6/Q=";

  doCheck = false;

  meta = {
    description = "Template rendering utility";
    license = with licenses; [ mit asl20 ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}
