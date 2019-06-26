{ stdenv, fetchzip, numactl, ncurses5, libxml2, zlib }:

stdenv.mkDerivation rec {
  pname = "intel-openclrt";
  version = "2019.8.4.0";

  src = fetchzip {
    url = "https://github.com/intel/llvm/releases/download/expoclcpu-1.0.0/oclcpuexp.tar.gz";
    sha256 = "0bq42yfynf3gvs43dj7c6h0y46b4d7ay0s0ambvd4ks5b0gkwkdh";
    stripRoot = false;
  };

  sourceRoot = ".";

  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc.lib numactl ncurses5 libxml2 zlib ];

  patchPhase = ''
    runHook prePatch

    # Remove `libOpenCL.so`, since we use ocl-icd's `libOpenCL.so` instead and this would cause a
    # clash.
    rm source/oclcpuexp/libOpenCL.so*
    for lib in source/oclcpuexp/*.so*; do
      patchelf --set-rpath "${libPath}:$out/lib/" $lib || true
    done

    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild
    echo "$out/lib/libintelocl.so" > intel_expcpu.icd
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 0644 source/oclcpuexp/*.rtl -t $out/lib/
    install -D -m 0644 source/oclcpuexp/*.o -t $out/lib/
    install -D -m 0755 source/oclcpuexp/*.so* -t $out/lib/
    install -D -m 0644 intel_expcpu.icd -t $out/etc/OpenCL/vendors

    runHook postInstall
  '';

  meta = {
    description = "Official OpenCL runtime for Intel CPUs";
    homepage    = https://software.intel.com/en-us/articles/opencl-drivers;
    license     = stdenv.lib.licenses.unfree;
    platforms   = [ "x86_64-linux" ];
    maintainers = [ stdenv.lib.maintainers.davidtwco ];
  };
}
