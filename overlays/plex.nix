self: super:

# This file contains a custom Nix overlay with Plex Pass packages.

{
  plexPassRaw = super.unstable.plexRaw.overrideAttrs (
    old: rec {
      version = "1.18.2.2041-3d469cb32";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
        sha256 = "0md9zg1r7drdg84ij5sbgcv6xd1ikjxvqgni3y32djqxrma1rw4f";
      };
    }
  );

  plexPass = super.unstable.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
