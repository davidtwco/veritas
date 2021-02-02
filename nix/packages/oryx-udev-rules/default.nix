{ stdenv, lib }:

stdenv.mkDerivation rec {
  pname = "oryx-udev-rules";
  version = "unstable-20200820";

  # Source: https://github.com/zsa/wally/wiki/Live-training-on-Linux
  src = [ ./oryx.rules ];

  unpackPhase = ":";

  installPhase = ''
    install -Dpm644 $src $out/lib/udev/rules.d/50-oryx.rules
  '';

  meta = with lib; {
    homepage = "https://github.com/zsa/wally/wiki/Live-training-on-Linux";
    description = "udev rules that give NixOS permission to communicate with Oryx keyboards";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = with maintainers; [ davidtwco ];
  };
}
