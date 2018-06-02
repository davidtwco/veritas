{ config, pkgs, ... }:

{
  # Enable audio.
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable media keys.
  sound.mediaKeys = {
    enable = true;
    volumeStep = "5%";
  };
}
