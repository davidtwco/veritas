{ ... }:
{
  # Make function composition easier.
  compose = f: g: x: f (g x);
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
