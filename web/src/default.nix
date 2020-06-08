{ site }:

site.mkSite {
  name = "davidtw.co";
  routes = {
    "/index.html" = site.mkHtmlPage ./templates ./content/index.md;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
