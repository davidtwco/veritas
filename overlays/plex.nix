self: super:

# This file contains a custom Nix overlay with Plex Pass packages.

{
  plexPassRaw = super.unstable.plexRaw.overrideAttrs (
    old: rec {
      version = "1.18.1.1973-0f4abfbcc";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
        sha256 = "1lmj4yal1f072w5rwxn9m09lbclzy87xnvy89iva1kmqzl3bfz2q";
      };
    }
  );

  plexPass = super.unstable.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
