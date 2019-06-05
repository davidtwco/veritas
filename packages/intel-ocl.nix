{ stdenv, fetchzip, rpmextract, ncurses5, numactl, zlib }:

stdenv.mkDerivation rec {
  name = "intel-ocl-${version}";
  version = "18.1.0.013";

  src = fetchzip {
    url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/vcp/13793/l_opencl_p_${version}.tgz";
    sha256 = "1q2w4ijkf71glyqaf89hvl4z6pfxpsh194mqqd9yx7qcxiwj2bj4";
    stripRoot = false;
  };

  buildInputs = [ rpmextract ];

  sourceRoot = ".";
  compilerRoot = "./opt/intel/opencl_compilers_and_libraries_${version}/linux/compiler";

  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc.lib ncurses5 numactl zlib ];

  # Extract the RPMs contained within the source archive.
  postUnpack = ''
    rpmextract ./source/l_opencl_p_${version}/rpm/intel-openclrt-${version}-18.1.0-013.x86_64.rpm
  '';

  # Remove `libOpenCL.so`, since we use ocl-icd's `libOpenCL.so` instead and this would cause a
  # clash; and patch shared libraries.
  patchPhase = ''
    runHook prePatch

    rm ${compilerRoot}/lib/intel64_lin/libOpenCL.so*
    for lib in ${compilerRoot}/lib/intel64_lin/*.so; do
      patchelf --set-rpath "${libPath}:$out/lib/intel-ocl" $lib || true
    done

    runHook postPatch
  '';

  # Create ICD file, which just contains the path of the corresponding shared library.
  buildPhase = ''
    runHook preBuild
    echo "$out/lib/intel-ocl/libintelocl.so" > intel64.icd
    runHook postBuild
  '';

  # Install into $out directory.
  installPhase = ''
    runHook preInstall

    install -D -m 0644 ${compilerRoot}/lib/*.rtl -t $out/lib/
    install -D -m 0755 ${compilerRoot}/lib/intel64_lin/*.so* -t $out/lib/intel-ocl
    install -D -m 0644 ${compilerRoot}/lib/intel64_lin/*.{bin,cfg,o,rtl} -t $out/lib/intel-ocl
    install -D -m 0644 intel64.icd -t $out/etc/OpenCL/vendors

    runHook postInstall
  '';

  # Libraries are stripped manually by the package.
  dontStrip = true;

  meta = {
    description = "Official OpenCL runtime for Intel CPUs";
    homepage    = https://software.intel.com/en-us/articles/opencl-drivers;
    license     = stdenv.lib.licenses.unfree;
    platforms   = [ "x86_64-linux" ];
    maintainers = [ stdenv.lib.maintainers.davidtwco ];
  };
}
