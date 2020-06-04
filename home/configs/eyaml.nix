{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.eyaml;
in
{
  options.veritas.configs.eyaml = mkEnableOption "eyaml configuration";

  config = mkIf cfg.enable {
    home.file.".eyaml/config.yaml".text = ''
      ---
      pkcs7_private_key: './keys/eyaml/private_key.pkcs7.pem'
      pkcs7_public_key: './keys/eyaml/public_key.pkcs7.pem'
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
