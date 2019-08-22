{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "workman";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "davidtwco";
    repo = "workman";
    rev = "c2e07c8e9bf8137e1ba6b13535f09c012a27fe78";
    sha256 = "15rcb0qs5w6z2fz5kbwf3adrf3cfnavyzqvirgavz36bn839ic54";
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
