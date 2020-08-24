self: super:

{
  plexPassRaw = super.plexRaw.overrideAttrs (
    old: rec {
      version = "1.20.1.3213-67a1137a9";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
        sha256 = "15al8lbg3h07gwa6wkdlisr03kz9pl4pdkvm7733gpi9713lqqqj";
      };
    }
  );

  plexPass = super.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
