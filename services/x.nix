{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "gb";
    dpi = 160;

    displayManager.slim.enable = true;

    windowManager.i3.enable = true;
    windowManager.i3.package = pkgs.i3-gaps;
    windowManager.default = "i3";

    synaptics = {
      enable = true;
      twoFingerScroll = true;
      tapButtons = true;
      accelFactor = "0.01";
      palmDetect = true;
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

  fonts.fontconfig.dpi = 160;
}
