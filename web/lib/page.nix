{ pkgs, lib, site }:
let
  inherit (site.conversion) convertHtml';
  inherit (site.frontmatter) extractFrontmatter;
  inherit (site.template) renderTemplate;
in
rec {
  # Apply a template (determined by the `template` attribute in `path`'s frontmatter) to the
  # content of `path`, rendered as HTML.
  mkHtmlPageWithContext = templatesPath: path: extraContext:
    let
      content = convertHtml' path;
      frontmatter = extractFrontmatter path;
      context = { inherit content; } // frontmatter // extraContext;
    in
    renderTemplate templatesPath context path;

  # Render content as HTML page without extra context.
  mkHtmlPage = templatesPath: path: mkHtmlPageWithContext templatesPath path { };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
