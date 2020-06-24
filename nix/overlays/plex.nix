self: super:

{
  plexPassRaw = super.plexRaw.overrideAttrs (
    old: rec {
      version = "1.19.4.2935-79e214ead";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
        hash = "sha256-BGxNGAZL+Uyk7dKzrFuRgQng4XY9903jyt4qmVBu63M=";
      };
    }
  );

  plexPass = super.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
