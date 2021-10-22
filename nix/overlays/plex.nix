self: super:

{
  plexPassRaw = super.plexRaw.overrideAttrs (
    old: rec {
      version = "1.24.5.5160-19d8ce86f";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
        sha256 = "1vf94h6rq8ldy56j51ykczlrhnaaiibm7slw05r196190jm38i6r";
      };
    }
  );

  plexPass = super.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
