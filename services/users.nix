{ config, pkgs, ... }:

{
  users.extraUsers.david = {
    description = "David Wood";
    extraGroups = [
      "audio" "disk" "video" "wheel" "docker" "libvirtd" "plugdev" "systemd-journal" "vboxusers"
    ];
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    hashedPassword = "$6$kvMx6lEzQPhkSj8E$KfP/qM2cMz5VqNszLjeOBGnny3PdIyy0vnHzIgP.gb1XqTI/qq3nbt0Qg871pkmwJwIu3ZGt57yShMjFFMR3x1";
    openssh.authorizedKeys.keys = [
      # Original SSH key.
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACovZYUzoZ5Q+dn6XNK/wipU73xCNXhqe2iUFtafGleSRfktma2kpPOX+UvgUiW4z+WNd5RYs1uMUqvnRDt+ZfUPgB4OgO6gGp2hwfHBS5px1FmQo6e5Ia7ts5698zKfg9klHq0zF7sk/FXgNI7xguvt48lJJf9lN6Jyunh1SSCP5vrbQ== david@davidtw.co"
      # GPG from YubiKey.
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC4gTcNODjVG2ojIsgv/ProYIPzljwzqPwPcvlguKO6O3bHCk0nP0VjG+hSFE+hxnBgYElab1dPOeO9nNYjEMNX1jDrqEWN7W8OK0HuKmbnNkYu8ddtgP/qoO/oLZKJhTrFPNsX4my8fdbKzDXahMwk6lIEihe/paGO45Iui7x+JutTZYFXhZPHoHKf8jkcBHnSGxbxYw9Y0qG1Jl9BOn9UEznjeQnvaqFKbR6uUae0W6T8xe5xDUNM9Rs3Fz2hutH4yWYPMcM+wkHG0jI1wNxWYpVPGGrpRaK1mUz0Z+pztGs99xzUO/ztCwhxDlX+TxZ5RCg5f/lgbZh1Z+jsUO3RXF/gJyctI6yvwZ+C2rwqN2dDUPlgcbUQEFSQZjZlLb0ssh/LbmMKOAuyVPU8KrHy2Z8FcYR3KBQzurU3CzYoCJbjTmq8BtIryzNs6x4XvON1cyiezWAWnmLFDGLUE5OivuII8eDjVzUiWmouDfuMa8PcQC6yyhLZ/jwFyK9+HIZrY2lWoBas5QhGxPNQFOTeR2yb/67XMQXKAA0CB4q+TCiMKt+RBlqhK275KbMOjH7ToOQJb0i3e3Cm0g3epAJ4IUEQewi/HUSV4w8SLIzpDyRmMVUEFSwOyfC4QCsMkcPIpufKQZ5q5G/4CrwL+gYaYV8UeditCFb9pS67qDHww== david@davidtw.co"
    ];
  };

  # Do not allow users to be added or modified except through Nix configuration.
  users.mutableUsers = false;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
