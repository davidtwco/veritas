{ stdenv, fetchFromGitHub, opencl-clhpp, cmake, withDebug ? false }:

stdenv.mkDerivation rec {
  name = "khronos-icd-loader-${version}";
  version = "25e7faa";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-ICD-Loader";
    rev = "25e7faa6de5da4edeed48e4d8763730f29fdd3ef";
    sha256 = "0bxd7caw94avglrw5jvd2iwdjs51vv4lgp1pgf5njfyvbarg1hbn";
  };

  patches = stdenv.lib.lists.optional withDebug ./debug.patch;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ opencl-clhpp ];

  meta = with stdenv.lib; {
    description = "Offical Khronos OpenCL ICD Loader";
    homepage = https://github.com/KhronosGroup/OpenCL-ICD-Loader;
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ davidtwco ];
  };
}
