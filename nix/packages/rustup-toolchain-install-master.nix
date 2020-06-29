{ stdenv, fetchFromGitHub, rustPlatform, darwin, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "rustup-toolchain-install-master";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "kennytm";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-J25ER/g8Kylw/oTIEl4Gl8i1xmhR+4JM5M5EHpl1ras=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = (stdenv.lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security) ++ [
    openssl
  ];

  cargoSha256 = "sha256:CxBbN3t6C3ngovR99Yk6/1B53c26YnGDMSfwHA01e+o=";

  meta = with stdenv.lib; {
    description = "Install a rustc master toolchain usable from rustup";
    homepage = "https://github.com/kennytm/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
