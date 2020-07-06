{ ... }:

{
  home.stateVersion = "19.03";

  veritas = {
    configs = {
      autorandr.profile = {
        fingerprint = {
          "HDMI-1" = "00ffffffffffff0010acbaa0553039322e1c010380342078ea0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00374d543031384245323930550a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a20202020202001b8020322f14f9005040302071601141f12132021222309070765030c00100083010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e960006442100001800000000000000000000000000000000000000000082";
        };
        config = {
          "HDMI-1" = {
            enable = true;
            mode = "1920x1200";
            primary = true;
            position = "0x0";
            rate = "59.95";
          };
        };
      };

      mail.email = "david.wood@codeplay.com";
    };

    profiles = {
      desktop.enable = true;
      development.enable = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
