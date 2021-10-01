{ lib, ... }:

with lib;
{
  home.stateVersion = "20.09";

  veritas = {
    configs = {
      gnupg.enable = mkForce false;
      mail.email = "david.wood@huawei.com";
    };
    profiles = {
      development.enable = true;
      homeManagerOnly.enable = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
