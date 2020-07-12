self: super:

{
  iosevka-fixed = super.iosevka.override { set = "fixed"; };
  iosevka-term = super.iosevka.override { set = "term"; };

  iosevka-slab = super.iosevka.override { set = "slab"; };
  iosevka-fixed-slab = super.iosevka.override { set = "fixed-slab"; };
  iosevka-term-slab = super.iosevka.override { set = "term-slab"; };

  iosevka-curly = super.iosevka.override { set = "curly"; };
  iosevka-fixed-curly = super.iosevka.override { set = "fixed-curly"; };
  iosevka-term-curly = super.iosevka.override { set = "term-curly"; };

  iosevka-curly-slab = super.iosevka.override { set = "curly-slab"; };
  iosevka-fixed-curly-slab = super.iosevka.override { set = "fixed-curly-slab"; };
  iosevka-term-curly-slab = super.iosevka.override { set = "term-curly-slab"; };

  iosevka-aile = super.iosevka.override { set = "aile"; };
  iosevka-etoile = super.iosevka.override { set = "etoile"; };
  iosevka-sparkle = super.iosevka.override { set = "sparkle"; };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
