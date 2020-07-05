{ config, ... }:

{
  home.stateVersion = "19.03";

  veritas = {
    configs = {
      autorandr.profile = {
        fingerprint = {
          "DP-2" = "00ffffffffffff001e6d077749dc0400061c0104b53c22789f3e31ae5047ac270c50542108007140818081c0a9c0d1c08100010101014dd000a0f0703e803020650c58542100001a286800a0f0703e800890650c58542100001a000000fd00283d878738010a202020202020000000fc004c472048445220344b0a20202001e60203197144900403012309070783010000e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
          "DP-4" = "00ffffffffffff001e6d077742dc0400061c0104b53c22789f3e31ae5047ac270c50542108007140818081c0a9c0d1c08100010101014dd000a0f0703e803020650c58542100001a286800a0f0703e800890650c58542100001a000000fd00283d878738010a202020202020000000fc004c472048445220344b0a20202001ed0203197144900403012309070783010000e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
        };
        config = {
          "DP-4" = {
            dpi = 163;
            enable = true;
            mode = "3840x2160";
            position = "3840x0";
            rate = "60.00";
          };
          "DP-2" = {
            dpi = 163;
            enable = true;
            mode = "3840x2160";
            position = "0x0";
            primary = true;
            rate = "60.00";
          };
        };
      };

      i3.colourScheme = {
        highlight = config.veritas.profiles.common.colourScheme.yellow;
        highlightBright = config.veritas.profiles.common.colourScheme.brightYellow;
      };

      xsession.nvidiaSettings = {
        "AllowGSYNCCompatible" = "On";
        # See nixpkgs#34977.
        "ForceFullCompositionPipeline" = "On";
      };
    };

    profiles = {
      common.enable = true;
      desktop = {
        enable = true;
        uiScale = 1.5;
      };
      development.enable = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
