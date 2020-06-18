{ pkgs, lib, site }:
let
  inherit (lib.trivial) importJSON;
  inherit (site.derivation) mkDerivation;
in
{
  # Extract the YAML frontmatter from a file using pandoc.
  extractFrontmatter = path:
    let
      name = builtins.baseNameOf (toString path);
      tmpl = pkgs.writeText "site-frontmatter.pandoc-tpl" "$meta-json$";
      drv = mkDerivation {
        name = "frontmatter-${name}.json";
        inputs = with pkgs; [ pandoc ];
        command = ''
          # Must specify `-t html` even though template will mean that all output is in JSON. If
          # `-t` is not provided, then output format will be inferred from the extension and JSON
          # AST output from pandoc will override template.
          pandoc -t html --template ${tmpl} ${path} -o $out
        '';
      };
    in
    importJSON "${drv}";
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
