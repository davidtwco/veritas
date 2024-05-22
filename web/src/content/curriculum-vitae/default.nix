{ stdenv, lib, gitignoreSource, typst }:

stdenv.mkDerivation rec {
  name = "curriculum_vitae.pdf";

  src = gitignoreSource ./.;

  nativeBuildInputs = [ typst ];

  buildPhase = ''
    runHook preBuild
    typst compile ./default.typ --font-path ./fonts
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
    platforms = [ "x86_64-linux" "aarch64-darwin" ];
    maintainers = [ lib.maintainers.davidtwco ];
  };
}
