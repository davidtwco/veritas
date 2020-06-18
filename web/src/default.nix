{ pkgs, site }:
let
  browserConfigData = pkgs.writeText "site-browserconfig.xml" ''
    <browserconfig>
      <msapplication>
        <tile>
          <square70x70logo src="favicons/mstile-70x70.png"/>
          <square150x150logo src="favicons/mstile-150x150.png"/>
          <wide310x150logo src="favicons/mstile-310x150.png"/>
          <square310x310logo src="favicons/mstile-310x310.png"/>
          <TileColor>#141414</TileColor>
        </tile>
      </msapplication>
    </browserconfig>
  '';
  manifestData = {
    "name" = "David Wood";
    "short_name" = "David Wood";
    "description" = "Personal website of David Wood";
    "dir" = "auto";
    "lang" = "en-GB";
    "display" = "standalone";
    "orientation" = "portrait";
    "start_url" = "/";
    "background_color" = "#141414";
  };
in
site.mkSite {
  name = "davidtw.co";
  routes = {
    "/index.html" = site.mkHtmlPageWithContext ./templates ./content/index.md {
      header = builtins.readFile ./content/header.html;
      # Given that `mkHtmlPageWithContext` basically just inserts the content of `index.md` into
      # a `content` attribute in the context and then renders, we can also add the header and
      # footer content using the same mechanism:
      footer = site.convertHtml' ./content/footer.md;
    };

    "/css" = ./css;
    "/fonts" = ./fonts;
    "/images" = ./images;
    "/favicons" = site.generateFaviconsWithExtraCommands browserConfigData ./favicon.png manifestData;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
