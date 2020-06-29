{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.bash;
in
{
  options.veritas.configs.bash = {
    enable = mkEnableOption "bash configuration";

    wslCompatibility = mkOption {
      type = types.bool;
      default = false;
      description = "`exec` into the user's actual shell as is required in WSL 1.";
    };
  };

  config = mkIf cfg.enable {
    programs.bash = with lib; {
      enable = true;
      profileExtra =
        optionalString (cfg.wslCompatibility) "exec ${config.home.profileDirectory}/bin/fish";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
