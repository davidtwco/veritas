{ stdenv, lib, gitignoreSource, texlive }:

stdenv.mkDerivation rec {
  name = "curriculum_vitae.pdf";

  src = gitignoreSource ./.;

  nativeBuildInputs = [
    (texlive.combine {
      inherit (texlive) amsfonts amsmath fancyhdr fontspec hyperref preprint scheme-basic xcolor;
      inherit (texlive) xetex;
    })
  ];

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
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.davidtwco ];
  };
}
