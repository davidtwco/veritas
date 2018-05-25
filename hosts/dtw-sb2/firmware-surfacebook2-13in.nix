with import <nixpkgs> {};

let
  version = "4.16.7-1";
  checksum = "04f91i6msb71yc2l7grjdf85a0dpk6nhrs740j3yi6p44zqnzswf";
in stdenv.mkDerivation {
  name = "firmware-surfacebook2-13in-${version}";

  src = fetchFromGitHub {
    owner = "jakeday";
    repo = "linux-surface";
    rev = version;
    sha256 = checksum;
  };

  buildInputs = [ pkgs.unzip ];

  # These specific firmware archives are selected by reviewing the `setup.sh`
  # script in the linux-surface repository and looking at the correct device.
  # In particular, this derivation looks for the Surface Book 2 13in model - that
  # is, an SKU of Surface_Book_1832.
  installPhase = ''
    mkdir -p $out/lib/firmware/intel/ipts
    unzip -o firmware/ipts_firmware_v137.zip -d $out/lib/firmware/intel/ipts/

    mkdir -p $out/lib/firmware/i915
    unzip -o firmware/i915_firmware_kbl.zip -d $out/lib/firmware/i915/

    mkdir -p $out/lib/firmware/nvidia/gp108
    unzip -o firmware/nvidia_firmware_gp108.zip -d $out/lib/firmware/nvidia/gp108/

    mkdir -p $out/lib/firmware/mrvl
    unzip -o firmware/mrvl_firmware.zip -d $out/lib/firmware/mrvl/
  '';

  # Firmware blobs do not need fixing!
  dontFixup = true;

  meta = with stdenv.lib; {
    description = "Binary firmware for Surface Book 2";
    homepage = "https://github.com/jakeday/linux-surface";
    platforms = platforms.linux;
    maintainers = with maintainers; [ davidtwco ];
    priority = 6;
  };
}
