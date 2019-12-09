{ stdenv, fetchzip, pkg-config, installShellFiles, ncurses5, ocl-icd, zlib }:

stdenv.mkDerivation rec {
  name = "computecpp-${version}";
  version = "1.1.6";

  src = fetchzip {
    url = "https://computecpp.codeplay.com/downloads/computecpp-ce/${version}/ubuntu-16.04-64bit.tar.gz";
    sha256 = "0w3ibaiaa6hk43hbbb87y4lbgvlw3bjlj9vix9z947fjv4p15f0h";
    stripRoot = true;
  };

  dontStrip = true;

  nativeBuildInputs = [
    # Adds `lib/pkgconfig` to `PKG_CONFIG_PATH`.
    pkg-config
    # Looks for shell completions and manpages.
    installShellFiles
  ];

  patchPhase = let
    binaries = [
      # Not `compute` and `compute-cl` -- these are symlinks.
      "compute++"
      "computecpp_info"
      "ld.ldd"
      "ldd"
      "ldd-link"
      "llvm-spirv"
      "module-pack-wrapper"
      "sycl-bundler"
    ];
    libaries = stdenv.lib.makeLibraryPath [
      stdenv.cc.cc.lib
      ncurses5
      ocl-icd
      zlib
    ];
  in
    ''
      runHook prePatch

      for bin in ${builtins.concatStringsSep " " binaries}; do
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${libaries}:$out/lib/" ./bin/$bin || true
      done

      patchelf --set-rpath "${libaries}:$out/lib/" ./lib/libComputeCpp.so || true

      runHook postPatch
    '';

  installPhase = ''
    runHook preInstall

    find ./lib -type f -exec install -D -m 0755 {} -t $out/lib \;
    find ./bin -type l -exec install -D -m 0755 {} -t $out/bin \;
    find ./bin -type f -exec install -D -m 0755 {} -t $out/bin \;
    find ./doc -type f -exec install -D -m 0644 {} -t $out/doc \;
    find ./include -type f -exec install -D -m 0644 {} -t $out/include \;

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description =
      "Accelerate Complex C++ Applications on Heterogeneous Compute Systems using Open Standards";
    homepage = https://www.codeplay.com/products/computesuite/computecpp;
    license = licenses.unfree;
    maintainers = with maintainers; [ davidtwco ];
    platforms = [ "x86_64-linux" ];
  };
}
