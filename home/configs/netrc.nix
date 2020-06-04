{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.netrc;
in
{
  options.veritas.configs.netrc.enable = mkEnableOption "netrc configuration";

  config = mkIf cfg.enable {
    home.file.".netrc".text = ''
      machine github.com
      login davidtwco
      password ${builtins.readFile ../secrets/github-api-token}

      machine api.github.com
      login davidtwco
      password ${builtins.readFile ../secrets/github-api-token}
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
