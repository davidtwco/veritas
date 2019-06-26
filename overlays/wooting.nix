self: super:

# This file contains a custom Nix overlay with Wooting packages.

{
  wootility = super.callPackage ../packages/wootility.nix {
    appimageTools = super.unstable.appimageTools;
    wooting-udev-rules = self.wooting-udev-rules;
  };
  wooting-udev-rules = super.callPackage ../packages/wooting-udev-rules {};
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
