{ pkgs, lib, site }:
let
  inherit (site.derivation) mkDerivation;
in
{
  # Render a template in `templatesPath` with `context`.
  renderTemplate = templatesPath: context:
    let
      name = context.template;
      ctx = builtins.toFile "site-render-template-${name}" (builtins.toJSON context);
      drv = mkDerivation {
        name = "render-${name}";
        inputs = [ pkgs.tera-template ];
        command =
          "tera-template -c ${ctx} -p ${templatesPath} -t ${name} > $out";
      };
    in
    "${drv}";
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
