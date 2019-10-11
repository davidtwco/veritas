self: super:

# This file contains a custom Nix overlay with Plex Pass packages.

{
  plexPassRaw = super.unstable.plexRaw.overrideAttrs (
    old: rec {
      version = "1.18.0.1913-e5cc93306";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
        sha256 = "02wl261nb15ys5rwv97c33d2yca00y8spnzq34dy7j9inz48zqp8";
      };
    }
  );

  plexPass = super.unstable.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
