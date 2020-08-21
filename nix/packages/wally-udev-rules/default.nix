{ stdenv }:

stdenv.mkDerivation rec {
  pname = "wally-udev-rules";
  version = "unstable-20200821";

  # Source: https://github.com/zsa/wally/wiki/Linux-install
  src = [ ./wally.rules ];

  unpackPhase = ":";

  installPhase = ''
    install -Dpm644 $src $out/lib/udev/rules.d/50-wally.rules
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/zsa/wally";
    description = "udev rules that give NixOS permission to flash ZSA keyboards with Wally";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = with maintainers; [ davidtwco ];
  };
}
