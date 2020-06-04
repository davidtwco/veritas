{ lib, system }:
self: super:

lib.optionalAttrs (system == "x86_64-linux") {
  plexPassRaw = super.plexRaw.overrideAttrs (
    old: rec {
      version = "1.19.3.2831-181d9145d";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
        sha256 = "0igm3p1b63gl214zsjk9nnw39f9r7mc5gb40dqf31l90pnvfciq7";
      };
    }
  );

  plexPass = super.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
