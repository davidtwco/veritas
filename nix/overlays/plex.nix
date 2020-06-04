{ lib, system }:
self: super:

lib.optionalAttrs (system == "x86_64-linux") {
  plexPassRaw = super.plexRaw.overrideAttrs (
    old: rec {
      version = "1.19.4.2902-69560ce1e";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
        hash = "sha256-kH+GAXyYHxyp1OBvBw4N1jNis0SQLLkqvGNwXQyXHas=";
      };
    }
  );

  plexPass = super.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
