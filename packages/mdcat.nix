{ stdenv, fetchFromGitHub, rustPlatform, pkgconfig, openssl, Security }:

rustPlatform.buildRustPackage rec {
  pname = "mdcat";
  version = "0.13.0";

  doCheck = false;

  src = fetchFromGitHub {
    owner = "lunaryorn";
    repo = pname;
    rev = "mdcat-${version}";
    sha256 = "0xlcpyfmil7sszv4008v4ipqswz49as4nzac0kzmzsb86np191q0";
  };

  cargoSha256 = "16q17gm59lpjqa18q289cjmjlf2jicag12jz529x5kh11x6bjl8v";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ (stdenv.lib.optional stdenv.isDarwin Security) openssl ];

  meta = with stdenv.lib; {
    description = "cat for markdown";
    homepage = https://github.com/lunaryorn/mdcat;
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}
