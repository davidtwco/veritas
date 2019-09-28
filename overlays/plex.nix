self: super:

# This file contains a custom Nix overlay with Plex Pass packages.

{
  plexPassRaw = super.unstable.plexRaw.overrideAttrs (old: rec {
    version = "1.17.0.1709-982421575";
    name = "${old.pname}-${version}";
    src = super.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
      sha256 = "03c5f4ykr4frz1kv2ya3njrhlg8hb699xix0fzz9sc1547lz093x";
    };
  });

  plexPass = super.unstable.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
