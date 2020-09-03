{ appimageTools
, fetchurl
, lib
, gsettings-desktop-schemas
, gtk3
}:
let
  pname = "beekeeper-studio";
  version = "1.7.5";
in
appimageTools.wrapType2 rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/Beekeeper-Studio-${version}.AppImage";
    sha256 = "1i9g8da9qacsynw4y3pfsjnfpjlsdjs8viyac2bgc67x57ispp2a";
  };

  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS="${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS"
  '';

  multiPkgs = extraPkgs;
  extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs);
  extraInstallCommands = "mv $out/bin/{${name},${pname}}";

  meta = with lib; {
    homepage = "https://www.beekeeperstudio.io/";
    description = "Open Source SQL Editor and Database Manager";
    platforms = [ "x86_64-linux" ];
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ davidtwco ];
  };
}
