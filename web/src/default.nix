{ pkgs, site, extraRoutes ? { } }:
let
  curriculumVitae = pkgs.callPackage ./content/curriculum-vitae { };
  favicons = site.generateFaviconsWithExtraCommands browserConfigData ./favicon.png manifestData;

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
    # Keep this in sync with the GitHub profile readme in the `davidtwco/davidtwco` repository.
    "/index.html" = site.mkHtmlPageWithContext ./templates ./content/index.md {
      header = builtins.readFile ./content/header.html;
      # Given that `mkHtmlPageWithContext` basically just inserts the content of `index.md` into
      # a `content` attribute in the context and then renders, we can also add the header and
      # footer content using the same mechanism:
      footer = site.convertHtml' ./content/footer.md;
    };

    # This is the same path as the old website for backwards compatibility.
    "/cv.pdf" = curriculumVitae;
    "/curriculum_vitae.pdf" = curriculumVitae;

    "/css" = ./css;
    "/favicons" = favicons;
    "/favicon.ico" = "${favicons}/favicon.ico";
    "/fonts" = ./fonts;
    "/images" = ./content/images;
    "/media" = ./content/media;
  } // extraRoutes;
}
