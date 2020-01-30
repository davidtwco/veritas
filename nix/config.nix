# This file contains the configuration provided to `nixpkgs.config`. It is imported by NixOS and
# home-manager and placed at `$HOME/.config/nixpkgs/config.nix`.

{
  allowUnfree = true;

  allowBroken = true;

  firefox.enableGnomeExtensions = true;

  packageOverrides = pkgs: rec {
    plexPassRaw = pkgs.plexRaw.overrideAttrs (
      old: rec {
        version = "1.18.5.2309-f5213a238";
        name = "${old.pname}-${version}";
        src = pkgs.fetchurl {
          url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
          sha256 = "1w8v2v4i4bg3pr8rxxyc1zjkifihv1bhar7pb4dmf2qpbbcx1knw";
        };
      }
    );

    plexPass = pkgs.plex.override { plexRaw = plexPassRaw; };

    vaapiIntel = pkgs.vaapiIntel.override {
      enableHybridCodec = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
