{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.flake8;
in
{
  options.veritas.configs.flake8 = mkEnableOption "flake8 configuration";

  config = mkIf cfg.enable {
    # Configure the `flake8` linter for Python to match `black`'s formatting.
    xdg.configFile."flake8".text = ''
      [flake8]
      # Recommend matching the black line length (default 88),
      # rather than using the flake8 default of 79:
      max-line-length = 88
      extend-ignore =
          # See https://github.com/PyCQA/pycodestyle/issues/373
          E203,
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
