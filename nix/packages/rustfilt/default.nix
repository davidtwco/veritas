{ stdenv, lib, fetchFromGitHub, rustPlatform, darwin }:

rustPlatform.buildRustPackage rec {
  pname = "rustfilt";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "luser";
    repo = "rustfilt";
    rev = version;
    sha256 = "096219q0d2i3c2awczlv64dnyjpx2b5ml8fgd2xwly56wn8nvgfd";
  };

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  cargoSha256 = "sha256:rs2EWcvTxLVeJ0t+jLM75s+K72t+hqKzwy3oAdCZ8BE=";

  meta = with lib; {
    description = "Demangle Rust symbols";
    homepage = "https://github.com/luser/rustfilt";
    license = licenses.asl20;
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
