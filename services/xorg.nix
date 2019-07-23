{ config, pkgs, ... }:

let
  hasNvidiaDrivers = builtins.elem "nvidia" config.services.xserver.videoDrivers;
in
  {
    # X.org {{{
    # =====
    services.xserver = {
      enable = true;
      layout = "gb";

      desktopManager = {
        gnome3.enable = true;
        wallpaper.mode = "center";
      };

      displayManager.gdm = {
        enable = true;
        wayland = if hasNvidiaDrivers then false else true;
      };
    };

    services.gnome3.chrome-gnome-shell.enable = true;

    # Disable NetworkManager (it is enabled by Gnome) as it messes with systemd-networkd.
    networking.networkmanager.enable = false;
    # }}}

    # GTK Theme {{{
    # =========
    environment.etc."xdg/Trolltech.conf" = {
      text = ''
        [Qt]
        style=GTK+
      '';
      mode = "444";
    };

    environment.etc."xdg/gtk-3.0/settings.ini" = {
      text = ''
        [Settings]
        gtk-icon-theme-name="Arc"
        gtk-theme-name="Arc-Darker"
      '';
      mode = "444";
    };
    # }}}

    # Packages {{{
    # ========
    nixpkgs.config.firefox.enableGnomeExtensions = true;

    environment.systemPackages = with pkgs; [
      # Desktop utilities
      scrot xsel xlibs.xbacklight arandr pavucontrol paprefs xclip gnome3.gnome-tweaks hsetroot
      plotinus chrome-gnome-shell gnomeExtensions.dash-to-dock gnomeExtensions.topicons-plus
      gnomeExtensions.appindicator remmina peek

      # Browsers and IDEs
      firefox jetbrains.pycharm-community

      # Chat apps
      weechat mumble_git keybase-gui unstable.franz

      # Dotfiles
      rofi compton

      # Terminal
      unstable.alacritty

      # Desktop themes
      arc-icon-theme arc-kde-theme arc-theme
    ];

    programs = {
      # Change light from terminal.
      light.enable = true;

      # Add Ctrl+Shift+P menus to applications.
      plotinus.enable = true;
    };
    # }}}

    # Fonts {{{
    # =====
    fonts.fonts = with pkgs; [
      meslo-lg source-code-pro source-sans-pro source-serif-pro font-awesome_5 inconsolata
      siji material-icons powerline-fonts roboto roboto-mono roboto-slab iosevka
    ];
    # }}}
  }

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
