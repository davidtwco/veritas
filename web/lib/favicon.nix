{ pkgs, lib, site }:
let
  inherit (site.derivation) mkDerivation;
  inherit (lib.strings) optionalString;

  defaultSizes = [
    { name = "apple-touch-icon"; size = "57x57"; type = "png"; }
    { name = "apple-touch-icon"; size = "60x60"; type = "png"; }
    { name = "apple-touch-icon"; size = "72x72"; type = "png"; }
    { name = "apple-touch-icon"; size = "76x76"; type = "png"; }
    { name = "apple-touch-icon"; size = "114x114"; type = "png"; }
    { name = "apple-touch-icon"; size = "120x120"; type = "png"; }
    { name = "apple-touch-icon"; size = "144x144"; type = "png"; }
    { name = "apple-touch-icon"; size = "152x152"; type = "png"; }
    { name = "apple-touch-icon"; size = "180x180"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "320x460"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "640x920"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "640x1096"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "750x1294"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "1182x2208"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "1242x2148"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "748x1024"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "768x1004"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "1496x2048"; type = "png"; }
    { name = "apple-touch-startup-image"; size = "1536x2008"; type = "png"; }
    { name = "favicon"; size = "32x32"; type = "png"; }
    { name = "favicon"; size = "16x16"; type = "png"; }
    { name = "android-chrome"; size = "192x192"; type = "png"; }
    { name = "mstile"; size = "70x70"; type = "png"; }
    { name = "mstile"; size = "144x144"; type = "png"; }
    { name = "mstile"; size = "150x150"; type = "png"; }
    { name = "mstile"; size = "310x150"; type = "png"; }
    { name = "mstile"; size = "310x310"; type = "png"; }
  ];

  mkResizeCommands = sizes: path:
    let
      mkCommand = defn: with defn; "convert ${path} -resize ${size} $out/${name}-${size}.${type}";
    in
    builtins.concatStringsSep "\n" (builtins.map mkCommand sizes);

  mkManifestData = sizes: extraManifestData:
    let
      mkIcon = defn:
        { type = "image/png"; sizes = defn.size; src = "favicons/${defn.name}-${defn.size}.png"; };
    in
    pkgs.writeText "site-manifest.json" (builtins.toJSON (
      { icons = builtins.map mkIcon sizes; } // extraManifestData
    ));
in
rec {
  # Generate a directory with the favicon converted into provided sizes and a `manifest.json`, with
  # extra commands.
  generateFaviconsWithExtraCommandsAndSizes = sizes: browserConfigFile: path: extraManifestData:
    let
      name = builtins.baseNameOf (toString path);
      drv = mkDerivation {
        name = "favicons";
        inputs = with pkgs; [ imagemagick ];
        command = ''
          mkdir -p $out
          ${mkResizeCommands sizes path}
          convert -resize x16 -gravity center -crop 16x16+0+0 ${path} \
            -flatten -colors 256 -background transparent $out/favicon.ico
          cp ${mkManifestData sizes extraManifestData} $out/manifest.json
          ${optionalString (!isNull browserConfigFile) "cp ${browserConfigFile} $out/browserconfig.xml"}
        '';
      };
    in
    "${drv}";

  # Generate a directory with the favicon converted into default sizes and a `manifest.json`, with
  # extra commands.
  generateFaviconsWithExtraCommands = generateFaviconsWithExtraCommandsAndSizes defaultSizes;

  # Generate a directory with the favicon converted into default sizes and a `manifest.json`.
  generateFavicons = generateFaviconsWithExtraCommands null;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
