{ site }:

site.mkSite {
  name = "davidtw.co";
  routes = {
    "/index.html" = site.mkHtmlPageWithContext ./templates ./content/index.md {
      # Given that `mkHtmlPageWithContext` basically just inserts the content of `index.md` into
      # a `content` attribute in the context and then renders, we can also add the header and
      # footer content using the same mechanism:
      header = site.convertHtml' ./content/header.md;
      footer = site.convertHtml' ./content/footer.md;
    };

    "/reboot.css" = ./static/reboot.css;
    "/site.css" = ./static/site.css;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
