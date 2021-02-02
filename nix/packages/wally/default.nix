{ stdenv, lib, fetchurl, makeDesktopItem, autoPatchelfHook, glib, gtk, libusb, webkitgtk }:
let
  pname = "wally";
  version = "2.0.0";
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
    sha256 = "1nh7grwxya3ncimbbs4svpwn6f7h9vcbp3lb9ipj31mqwlfxqvb1";
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
