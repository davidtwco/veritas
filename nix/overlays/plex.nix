self: super:

{
  plexPassRaw = super.plexRaw.overrideAttrs (
    old: rec {
      version = "1.30.0.6486-629d58034";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
        sha256 = "05al609d1kvrpkz22ghm5s1f7w38m9wpnn0jxfrjkl14ii4icpd2";
      };
    }
  );

  plexPass = super.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
