{ pkgs, lib, site }:
let
  inherit (site.derivation) mkDerivation;

  tera-template = pkgs.callPackage ../../nix/packages/tera-template { };
in
{
  # Render a template in `templatesPath` with `context`.
  renderTemplate = templatesPath: context:
    let
      name = context.template;
      ctx = builtins.toFile "site-render-template-${name}" (builtins.toJSON context);
      drv = mkDerivation {
        name = "render-${name}";
        inputs = [ tera-template ];
        command =
          "tera-template -c ${ctx} -p ${templatesPath} -t ${name} > $out";
      };
    in
    "${drv}";
}
