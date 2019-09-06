{ stdenv, fetchzip, numactl, ncurses5, libxml2, zlib }:

stdenv.mkDerivation rec {
  pname = "intel-openclrt";
  version = "2019.8.7.0.0725";

  src = fetchzip {
    url = "https://github.com/intel/llvm/releases/download/oclcpuexp-2019.8.7.0.0725_rel/oclcpuexp-2019.8.7.0.0725_rel.tar.gz";
    sha256 = "0zgmbxr8sj589q7bpg3ciw65fh7bxa4lh3cfjmx3civjkbvxy4sp";
    stripRoot = false;
  };

  dontStrip = true;
  dontPatchELF = true;

  sourceRoot = ".";

  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc.lib numactl ncurses5 libxml2 zlib ];

  patchPhase = ''
    runHook prePatch

    # Remove `libOpenCL.so`, since we use ocl-icd's `libOpenCL.so` instead and this would cause a
    # clash.
    rm source/x64/libOpenCL.so*
    for lib in source/x64/*.so*; do
      patchelf --set-rpath "${libPath}:$out/lib/x64" $lib || true
    done

    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild
    echo "$out/lib/x64/libintelocl.so" > intel_expcpu.icd
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 0644 source/*.rtl -t $out/lib/
    install -D -m 0644 source/x64/*.rtl -t $out/lib/x64
    install -D -m 0644 source/x64/*.o -t $out/lib/x64
    install -D -m 0755 source/x64/*.so* -t $out/lib/x64
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
