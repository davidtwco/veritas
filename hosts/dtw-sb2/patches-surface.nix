with import <nixpkgs> {};

let
  kernel_version = "4.16";
  version = "4.16.7-1";
  checksum = "04f91i6msb71yc2l7grjdf85a0dpk6nhrs740j3yi6p44zqnzswf";
in rec {
  repo = fetchFromGitHub {
    owner = "jakeday";
    repo = "linux-surface";
    rev = version;
    sha256 = checksum;
  };

  acpica = rec {
    name = "acpica";
    patch = "${repo}/patches/${kernel_version}/acpica.patch";
  };

  cameras = rec {
    name = "cameras";
    patch = "${repo}/patches/${kernel_version}/cameras.patch";
  };

  config = rec {
    name = "config";
    patch = null;
    # This is built up manually from config.patch in the linux-surface
    # repository - Nix struggles to apply the config patch normally.
    #
    # Exceptions:
    #  - `PCIEPORTBUS n` is omitted - it conflicts with a setting that Nix sets.
    #  - `INTEL_ATOMISP y` is omitted - it seems to be unused in 4.16 and so fails.
    #  - `VIDEO_IPU3_CIO2 m` is omitted - it seems to be unused in 4.16 and so fails.
    #  - `VIDEO_OV5693 m` is omitted - it seems to be unused in 4.16 and so fails.
    #  - `VIDEO_OV8865 m` is omitted - it seems to be unused in 4.16 and so fails.
    #  - `LOCALVERSION -surface` is omitted - it requires that a override of the kernel package happens so that directory names are right, that's a hassle.
    extraConfig = ''
      CFG80211_DEFAULT_PS n
      INTEL_IPTS m
      DRM_I915_ALPHA_SUPPORT y
      ACPI_SURFACE m
      DEBUG_INFO n
    '';
  };

  ipts = rec {
    name = "ipts";
    patch = "${repo}/patches/${kernel_version}/ipts.patch";
  };

  keyboards_and_covers = rec {
    name = "keyboards_and_covers";
    patch = "${repo}/patches/${kernel_version}/keyboards_and_covers.patch";
  };

  sdcard_reader = rec {
    name = "sdcard_reader";
    patch = "${repo}/patches/${kernel_version}/sdcard_reader.patch";
  };

  surfaceacpi = rec {
    name = "surfaceacpi";
    patch = "${repo}/patches/${kernel_version}/surfaceacpi.patch";
  };

  surfacedock = rec {
    name = "surfacedock";
    patch = "${repo}/patches/${kernel_version}/surfacedock.patch";
  };

  wifi = rec {
    name = "wifi";
    patch = "${repo}/patches/${kernel_version}/wifi.patch";
  };
}
