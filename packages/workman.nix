{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "workman";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "davidtwco";
    repo = "workman";
    rev = "48b881e7c0e093ffda175348248f6ffe50e3c103";
    sha256 = "14vma81x1skb7g9cngk1pmd8asksac9332aqpfvh31n15pxap9kw";
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
