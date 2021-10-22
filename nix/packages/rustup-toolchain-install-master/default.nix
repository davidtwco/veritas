{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, darwin
, pkg-config
, openssl
, runCommand
, patchelf
, zlib
}:

rustPlatform.buildRustPackage rec {
  pname = "rustup-toolchain-install-master";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "kennytm";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-J25ER/g8Kylw/oTIEl4Gl8i1xmhR+4JM5M5EHpl1ras=";
  };

  patches =
    let
      patchelfPatch = runCommand "0001-dynamically-patchelf-binaries.patch"
        {
          CC = stdenv.cc;
          patchelf = patchelf;
          libPath = "$ORIGIN/../lib:${lib.makeLibraryPath [ zlib ]}";
        }
        ''
          export dynamicLinker=$(cat $CC/nix-support/dynamic-linker)
          substitute ${./0001-dynamically-patchelf-binaries.patch} $out \
            --subst-var patchelf \
            --subst-var dynamicLinker \
            --subst-var libPath
        '';
    in
    lib.optionals stdenv.isLinux [ patchelfPatch ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = (lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security) ++ [
    openssl
  ];

  cargoSha256 = "sha256:n7t8Ap9hdhrjmtKjfdyozf26J7yhu57pedm19CunLF4=";

  meta = with lib; {
    description = "Install a rustc master toolchain usable from rustup";
    homepage = "https://github.com/kennytm/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
