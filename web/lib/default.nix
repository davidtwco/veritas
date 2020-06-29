{ pkgs, system }:
let
  lib = pkgs.lib;
  site = lib.makeExtensible (self:
    let
      callSite = file: args: import file ({ site = self; inherit pkgs lib; } // args);
    in
    {
      conversion = callSite ./conversion.nix { };
      derivation = callSite ./derivation.nix { inherit system; };
      favicon = callSite ./favicon.nix { };
      frontmatter = callSite ./frontmatter.nix { };
      helpers = callSite ./helpers.nix { };
      page = callSite ./page.nix { };
      site = callSite ./site.nix { };
      template = callSite ./template.nix { };
    });
in
{
  inherit (site) conversion derivation favicon frontmatter helpers page site template;

  # Re-exports for convenience.
  inherit (site.conversion) convert convert' convertHtml convertHtml';
  inherit (site.derivation) mkDerivation;
  inherit (site.favicon)
    generateFavicons generateFaviconsWithExtraCommands generateFaviconsWithExtraCommandsAndSizes;
  inherit (site.frontmatter) extractFrontmatter;
  inherit (site.page) mkHtmlPage mkHtmlPageWithContext;
  inherit (site.site) mkSite;
  inherit (site.template) renderTemplate;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
