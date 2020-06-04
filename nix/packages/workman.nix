{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "workman";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "davidtwco";
    repo = "workman";
    rev = "4306463f8d0bcfcca542a96f277625a4ec586a68";
    sha256 = "0nhx6cchr2j75schg1c52xbl5a2mc99906dx2zpxmgyd0dkqria1";
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

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
