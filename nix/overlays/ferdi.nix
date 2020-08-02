self: super:

{
  ferdi = super.ferdi.overrideAttrs (
    old: rec {
      version = "5.6.0-beta.2";
      name = "${old.pname}-${version}";
      src = super.fetchurl {
        url = "https://github.com/getferdi/ferdi/releases/download/v${version}/ferdi_${version}_amd64.deb";
        sha256 = "0shd7p4v3dkkxzzdyi1zsh60330pxb7m0897lcr2367hr0a0j69s";
      };
    }
  );
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
