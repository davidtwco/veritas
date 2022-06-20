{ lib, ... }:

with lib;
{
  home.stateVersion = "20.09";

  programs = {
    git.extraConfig.http.sslVerify = false;
    fish.interactiveShellInit = ''
      set -gx cntlm_host 127.0.0.1
      set -gx cntlm_port 3128
      set -gx cntlm_proxy 127.0.0.1:3128
      set -gx http_proxy http://127.0.0.1:3128
      set -gx https_proxy http://127.0.0.1:3128
      set -gx ftp_proxy http://127.0.0.1:3128
      set -gx no_proxy 127.0.0.*,*.huawei.com,localhost
    '';
  };

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
