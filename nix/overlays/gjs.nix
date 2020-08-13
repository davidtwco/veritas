self: super:

{
  gjs = super.gjs.overrideAttrs (
    _: rec {
      doCheck = false;
    }
  );
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
