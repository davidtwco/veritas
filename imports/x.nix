{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "gb";
    dpi = 200;

    displayManager.slim.enable = true;

    windowManager.i3.enable = true;
    windowManager.default = "i3";
  };

  fonts.fontconfig.dpi = 200;
}
