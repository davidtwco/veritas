{ stdenv, lib, fetchurl, makeDesktopItem, autoPatchelfHook, glib, gtk, libusb, webkitgtk }:
let
  pname = "wally";
  version = "2.1.1";
  description = "Flash your ZSA Keyboard the EZ way";

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "@out@/bin/${pname}";
    comment = description;
    desktopName = "Wally";
    genericName = "Wally";
    categories = "Development";
  };
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/zsa/${pname}/releases/download/${version}-linux/${pname}";
    hash = "sha256-RphLOXqKNIjUmCwBAJeVo9aCTsl7pfsX1S72l1HZEkI=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    glib
    gtk
    libusb
    webkitgtk
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    install -D $src $out/bin/${pname}
    ln -s ${desktopItem}/share/applications/* $out/share/applications/
  '';

  preFixup = ''
    sed "s|@out@|$out|g" -i $out/share/applications/${pname}.desktop
  '';

  meta = with lib; {
    inherit description;
    homepage = "https://github.com/zsa/wally";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = with maintainers; [ davidtwco ];
  };
}
