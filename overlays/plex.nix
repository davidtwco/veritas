self: super:

# This file contains a custom Nix overlay with Plex Pass packages.

{
  plexPassRaw = super.unstable.plexRaw.overrideAttrs (old: rec {
    version = "1.16.6.1592-b9d49bdb7";
    name = "${old.pname}-${version}";
    src = super.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
      sha256 = "12wff06nlvcssa6sf6vhxajfd1dnr9870xn9fac4q7gf0yayj27j";
    };
  });

  plexPass = super.unstable.plex.override { plexRaw = self.plexPassRaw; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
