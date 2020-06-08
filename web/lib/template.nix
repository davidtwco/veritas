{ pkgs, lib, site }:
let
  inherit (site.derivation) mkDerivation;
in
{
  # Render a template in `templatesPath` with `context`.
  renderTemplate = templatesPath: context: path:
    let
      name = builtins.baseNameOf (toString path);
      ctx = builtins.toFile "site-context-${name}" (builtins.toJSON context);
      drv = mkDerivation {
        name = "site-render-${name}";
        inputs = [ pkgs.tera-template ];
        command =
          "tera-template -c ${ctx} -p ${templatesPath} -t ${context.template} > $out";
      };
    in
    "${drv}";
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
