# This file contains the configuration provided to `nixpkgs.config`. It is imported by NixOS and
# home-manager and placed at `$HOME/.config/nixpkgs/config.nix`.

{
  allowUnfree = true;

  allowBroken = true;

  firefox.enableGnomeExtensions = true;

  packageOverrides = pkgs: rec {
    plexPassRaw = pkgs.unstable.plexRaw.overrideAttrs (
      old: rec {
        version = "1.18.3.2129-41af4e729";
        name = "${old.pname}-${version}";
        src = pkgs.fetchurl {
          url = "https://downloads.plex.tv/plex-media-server-new/${version}/redhat/plexmediaserver-${version}.x86_64.rpm";
          sha256 = "1xn4csd3hhf226nz3vfbsc48xvwbhvbwhrgliqv7865n8wb6yqlg";
        };
      }
    );

    plexPass = pkgs.unstable.plex.override { plexRaw = plexPassRaw; };

    vaapiIntel = pkgs.vaapiIntel.override {
      enableHybridCodec = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
