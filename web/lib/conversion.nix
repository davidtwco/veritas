{ pkgs, lib, site }:
let
  inherit (site.derivation) mkDerivation;
in
rec {
  # Convert content at `path` to `type` using pandoc and return path to converted file.
  convertType = type: path:
    let
      name = builtins.baseNameOf (toString path);
      drv = mkDerivation {
        name = "site-pandoc-${name}.${type}";
        inputs = with pkgs; [ pandoc ];
        command = "pandoc -t ${type} ${path} -o $out";
      };
    in
    "${drv}";

  convertHtml = convertType "html";
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
