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
      description = ''
        Add configuration for WSL compatibility. e.g. `exec` into the user's preferred shell.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.bash = with lib; {
      enable = true;
      profileExtra = mkAfter (
        optionalString (cfg.wslCompatibility) ''
          . "${config.home.homeDirectory}/.nix-profile/etc/profile.d/hm-session-vars.sh"
          exec ${config.home.profileDirectory}/bin/fish
        ''
      );
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
