{ stdenv, fetchzip, ncurses5, ocl-icd, zlib }:

stdenv.mkDerivation rec {
  name = "computecpp-${version}";
  version = "1.1.4";

  src = fetchzip {
    url = "https://computecpp.codeplay.com/downloads/computecpp-ce/${version}/ubuntu-16.04-64bit.tar.gz";
    sha256 = "0zjslxs2q9g4m7dn4bnh5bg3gdmaffcv6fncmrkqc4sgvbnjz0vr";
    stripRoot = true;
  };

  sourceRoot = ".";

  buildInputs = [];

  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc.lib ncurses5 ocl-icd zlib  ];

  patchPhase = ''
    runHook prePatch

    for bin in compute++ computecpp_info ld.ldd ldd ldd-link llvm-spirv sycl-bundler; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}:$out/lib/" source/bin/$bin || true
    done

    patchelf --set-rpath "${libPath}:$out/lib/" source/lib/libComputeCpp.so || true

    runHook postPatch
  '';

  installPhase = ''
    runHook preInstall

    find source/lib -type f -exec install -D -m 0755 {} -t $out/lib \;
    find source/bin -type f -exec install -D -m 0755 {} -t $out/bin \;
    find source/doc -type f -exec install -D -m 0644 {} -t $out/doc \;
    find source/include -type f -exec install -D -m 0644 {} -t $out/include \;

    runHook postInstall
  '';

  dontStrip = true;

  meta = {
    description = "Accelerate Complex C++ Applications on Heterogeneous Compute Systems using Open Standards";
    homepage    = https://www.codeplay.com/products/computesuite/computecpp;
    license     = stdenv.lib.licenses.unfree;
    platforms   = [ "x86_64-linux" ];
    maintainers = [ stdenv.lib.maintainers.davidtwco ];
  };
}
