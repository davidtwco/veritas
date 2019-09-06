{ stdenv, fetchFromGitHub, rustPlatform, Security }:

rustPlatform.buildRustPackage rec {
  pname = "diffr";
  version = "v0.1.1";

  doCheck = false;

  src = fetchFromGitHub {
    owner = "mookid";
    repo = pname;
    rev = version;
    sha256 = "0nz27vxi1waq49k131z06br7g20s2i1h2b35pqspd583gqmd5zx1";
  };

  cargoSha256 = "1j8ng1i8jgdzv8kynsdqlgqjrdsql7dc0gqn5id265vj22f8yf9d";

  nativeBuildInputs = [];
  buildInputs = (stdenv.lib.optional stdenv.isDarwin Security);

  meta = with stdenv.lib; {
    description = "Yet another diff highlighting tool";
    homepage = https://github.com/mookid/diffr;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}
