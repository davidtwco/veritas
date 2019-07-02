{ stdenv, fetchFromGitHub, opencl-clhpp, ocl-icd }:

stdenv.mkDerivation rec {
  name = "clinfo-${version}";
  version = "2.2.18.04.06";

  src = fetchFromGitHub {
    owner = "Oblomov";
    repo = "clinfo";
    rev = "${version}";
    sha256 = "0y2q0lz5yzxy970b7w7340vp4fl25vndahsyvvrywcrn51ipgplx";
  };

  buildInputs = [ opencl-clhpp ocl-icd ];

  NIX_LDFLAGS = [ "-lOpenCL" ];

  installPhase = ''
  install -Dm755 clinfo $out/bin/clinfo
  '';

  meta = with stdenv.lib; {
    description = "A simple command-line application that enumerates all possible (known) properties of the OpenCL platform and devices available on the system";
    homepage = https://github.com/Oblomov/clinfo;
    license = licenses.cc0;
    platforms = platforms.linux;
    maintainers = with maintainers; [ davidtwco ];
  };
}
