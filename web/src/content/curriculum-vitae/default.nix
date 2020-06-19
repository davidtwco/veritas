{ stdenv, gitignoreSource, texlive }:

stdenv.mkDerivation rec {
  name = "curriculum_vitae.pdf";

  src = gitignoreSource ./.;

  nativeBuildInputs = [ texlive.combined.scheme-full ];

  buildPhase = ''
    runHook preBuild
    xelatex ./default.tex
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -m 0644 ./default.pdf $out
    runHook postInstall
  '';

  meta = {
    description = "Curriculum vitae of David Wood";
    homepage = "https://davidtw.co";
    license = stdenv.lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [ stdenv.lib.maintainers.davidtwco ];
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
