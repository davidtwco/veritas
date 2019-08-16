{ config, pkgs, ... }:

{
  # Pulseaudio {{{
  # ==========
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  # }}}

  # Media Keys {{{
  # ==========
  sound.mediaKeys = {
    enable = true;
    volumeStep = "5%";
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
