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
  pname = "cargo-bisect-rustc";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-B9hPXMUzQEIuUO29J+02z8py0/UHbsvfyZDbxRhP/Hs=";
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
  buildInputs =
    (lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security)
    ++ [ openssl ];

  cargoSha256 = "sha256:yqi+bdOW2dbnMKWogs7lwCFhkAOjFl/7l14SR0F/mxw=";

  meta = with stdenv.lib; {
    description = "Bisects rustc, either nightlies or CI artifacts";
    homepage = "https://github.com/rust-lang/${pname}";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
