self: super:

{
  plexPassRaw = super.plexRaw.overrideAttrs (
    old: rec {
      version = "1.19.5.3112-b23ab3896";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
        sha256 = "0lh0yqpp1xyhb3bkc8wqg1afdyvaqhv3bmbyjqalpj2ikkk5lxwk";
      };
    }
  );

  plexPass = super.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
