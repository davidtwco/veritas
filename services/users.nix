{ config, pkgs, ... }:

{
  users.extraUsers.david = {
    description = "David Wood";
    extraGroups = [ "wheel" "docker" "libvirtd" ];
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    hashedPassword = "$6$kvMx6lEzQPhkSj8E$KfP/qM2cMz5VqNszLjeOBGnny3PdIyy0vnHzIgP.gb1XqTI/qq3nbt0Qg871pkmwJwIu3ZGt57yShMjFFMR3x1";
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACovZYUzoZ5Q+dn6XNK/wipU73xCNXhqe2iUFtafGleSRfktma2kpPOX+UvgUiW4z+WNd5RYs1uMUqvnRDt+ZfUPgB4OgO6gGp2hwfHBS5px1FmQo6e5Ia7ts5698zKfg9klHq0zF7sk/FXgNI7xguvt48lJJf9lN6Jyunh1SSCP5vrbQ== david@davidtw.co"
    ];
  };

  # Do not allow users to be added or modified except through Nix configuration.
  users.mutableUsers = false;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
