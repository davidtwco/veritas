{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "workman";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "davidtwco";
    repo = "workman";
    rev = "a0ee9ed501dc6bf4e56c6c95c8672adde31c8a22";
    sha256 = "0qmv67jnidx9yffrbww0p3gd643pcja1lrfqaqvc1r5d8c7m6qpa";
  };

  installPhase = ''
    install -Dm755 workman $out/bin/workman
    install -Dm755 workman_default_config $out/bin/workman_default_config
  '';

  meta = with stdenv.lib; {
    description = "Working directory management - automation of working directory creation and updating.";
    homepage = "https://github.com/davidtwco/workman";
    license = [ licenses.mit licenses.asl20 ];
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ davidtwco ];
  };
}
