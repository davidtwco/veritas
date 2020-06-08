{ pkgs, lib, site }:
let
  inherit (site.derivation) mkDerivation;
  inherit (site.helpers) compose;
in
rec {
  # Convert content at `path` to `type` using pandoc and return path to converted file.
  convert = type: path:
    let
      name = builtins.baseNameOf (toString path);
      drv = mkDerivation {
        name = "site-pandoc-${name}.${type}";
        inputs = with pkgs; [ pandoc ];
        command = "pandoc -t ${type} ${path} -o $out";
      };
    in
    "${drv}";

  # Convert content and return converted output.
  convert' = compose builtins.readFile convert;

  # Convert content to HTML and return path to converted file.
  convertHtml = convert "html";

  # Convert content to HTML and return converted output.
  convertHtml' = compose builtins.readFile convertHtml;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
