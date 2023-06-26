{ pkgs, lib, site }:
let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (site.derivation) mkDerivation;

  copyRoute = outputPath: inputPath: ''
    mkdir -p $out/"$(dirname ${outputPath})"
    cp -r ${inputPath} $out/${outputPath}
  '';
in
{
  # Primary entrypoint of the static site generator - given the site name and attrset of
  # routes, create a derivation containing the entire site.
  mkSite = { name, routes }:
    mkDerivation {
      inherit name;
      command = ''
        mkdir -p $out
        ${builtins.concatStringsSep "\n" (mapAttrsToList copyRoute routes)}
      '';
    };
}
