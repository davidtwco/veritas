{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "gb";

    displayManager.sddm.enable = true;

    windowManager.i3.enable = true;
    windowManager.i3.package = pkgs.i3-gaps;
    windowManager.default = "i3";

    synaptics = {
      enable = true;
      twoFingerScroll = true;
      tapButtons = true;
      accelFactor = "0.001";
      palmDetect = true;
      palmMinWidth = 3;
      additionalOptions = ''
        Option "VertScrollDelta" "-180"
        Option "HorizScrollDelta" "-180"
        Option "FingerLow" "40"
        Option "FingerHigh" "70"
        Option "Resolution" "270"
        Option "TapButton2" "3"
      '';
    };
  };

  # QT4/5 global theme
  environment.etc."xdg/Trolltech.conf" = {
    text = ''
      [Qt]
      style=GTK+
    '';
    mode = "444";
  };

  # GTK3 global theme (widget and icon theme)
  environment.etc."xdg/gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-icon-theme-name="Arc"
      gtk-theme-name="Arc-Darker"
    '';
    mode = "444";
  };
}
