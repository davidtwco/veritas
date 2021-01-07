self: super:

{
  ferdi = super.ferdi.overrideAttrs (
    old: rec {
      version = "5.6.0-beta.5";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://github.com/getferdi/ferdi/releases/download/v${version}/ferdi_${version}_amd64.deb";
        hash = "sha256-fDUzYir53OQ3O4o9eG70sGD+FJ0/4SDNsTfh97WFRnQ=";
      };
    }
  );
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
