{ inputs }:
self: super:

# TODO(FLAKE_LOCKFILE_UPDATE): See nixpkgs#90459 - workaround for nvidia driver on kernel 5.7.

{
  linuxPackages_latest = super.linuxPackages_latest.extend (self: super: {
    nvidiaPackages = super.nvidiaPackages // {
      beta = super.nvidiaPackages.beta.overrideAttrs (attrs: {
        patches = [ ./kernel-5.7.patch ];

        passthru =
          let
            settingsPackage = import "${inputs.nixpkgs}/pkgs/os-specific/linux/nvidia-x11/settings.nix" self.nvidiaPackages.beta "15psxvd65wi6hmxmd2vvsp2v0m07axw613hb355nh15r1dpkr3ma";
            persistencedPackage = import "${inputs.nixpkgs}/pkgs/os-specific/linux/nvidia-x11/persistenced.nix" self.nvidiaPackages.beta "13izz9p2kg9g38gf57g3s2sw7wshp1i9m5pzljh9v82c4c22x1fw";
          in
          {
            settings = super.callPackage settingsPackage {
              withGtk2 = true;
              withGtk3 = false;
            };

            persistenced = super.callPackage persistencedPackage { };
          };
      });
    };
  });
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
