{ ... }:
_: super:

{
  vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
