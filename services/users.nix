{ config, pkgs, ... }:

{
  # Define user accounts. Don't forget to set a password with ‘passwd’.
  users.extraUsers.david = {
    description = "David Wood";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
  };
}
