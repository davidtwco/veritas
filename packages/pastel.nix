{ stdenv, fetchFromGitHub, rustPlatform, Security }:

rustPlatform.buildRustPackage rec {
  pname = "pastel";
  version = "v0.5.2";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = pname;
    rev = version;
    sha256 = "0synajvz67sin788mkyk9jf2n4r0b6fc8yi3a2klswbb236i0sc3";
  };

  cargoSha256 = "1gwk7b1zqg1fkwh852r35788lnj6836np1xakzq2v56cyqyzz2d1";

  nativeBuildInputs = [];
  buildInputs = (stdenv.lib.optional stdenv.isDarwin Security);

  meta = with stdenv.lib; {
    description = "A command-line tool to generate, analyze, convert and manipulate colors";
    homepage = https://github.com/sharkdp/pastel;
    license = with licenses; [ asl20 /* or */ mit ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}
