{ pkgs, ... }:

# This file contains the configuration for languages, locales and keyboard layouts.

{
  home = {
    # Use a UK keyboard layout.
    keyboard.layout = "uk";
    # Cannot guarantee that "en_GB.UTF-8" is available or that we'll be able to generate it on
    # non-NixOS.
    language.base = if cfg.dotfiles.isNonNixOS then "en_US.UTF-8" else "en_GB.UTF-8";
    # Set other language variables and use nixpkgs' locale archive which always has `en_GB.utf8`.
    sessionVariables = {
      "LOCALE_ARCHIVE" = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      "LANGUAGE" = config.home.language.base;
      "LC_ALL" = config.home.language.base;
    }
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
