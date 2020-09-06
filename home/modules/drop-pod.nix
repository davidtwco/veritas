{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.drop-pod;
in
{
  options.veritas.drop-pod = {
    enable = mkEnableOption "a drop-pod for this host";

    extraCommands = mkOption {
      type = types.str;
      default = "";
      description = ''
        Extra commands that will be run in the entrypoint script after the `PATH` is set and before
        the shell is entered.
      '';
    };

    finalBundle = mkOption {
      type = types.package;
      visible = false;
      readOnly = true;
      description = "Bundle generated for drop-pod.";
    };

    mappedDirectories = mkOption {
      type = types.attrsOf types.str;
      default = { "/lib64" = "lib64"; "/lib" = "lib"; "/opt" = "opt"; };
      description = ''
        Directories which should be mapped into the chroot. By default, `/opt`, `/lib` and `/lib64`
        are mapped. `lib64` and `lib` can contain the interpreter on some distributions and so
        should be preserved for normal system tools to be accessed.
      '';
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Packages to be included in the drop-pod.";
    };

    preservedEnvironmentVariables = mkOption {
      type = types.listOf types.str;
      default = [ "PATH" ];
      description = ''
        Environment variables preserved across chroot. By default, `PATH` is preserved across the
        chroot, as this enables normal system tools to be accessed.
      '';
    };

    shell = mkOption {
      type = types.str;
      default = "${pkgs.bashInteractive}/bin/bash";
      description = "Shell that should be entered in the chroot.";
    };

    unpackDirectory = mkOption {
      type = types.str;
      default = "~/.cache";
      description = "Directory that bundle should be extracted to.";
    };
  };

  config = mkIf cfg.enable {
    veritas.drop-pod.finalBundle =
      let
        # Construct a extension to the `PATH` with the packages that should be available in the
        # drop-pod.
        path = builtins.concatStringsSep ":" (map (pkg: "${getBin pkg}/bin") cfg.packages);

        entrypoint = pkgs.writeScriptBin "entrypoint" ''
          #! ${pkgs.runtimeShell} -e
          # Set the PATH as the primary mechanism for making packages with configuration
          # available.
          PATH="${path}:$PATH"
          ${cfg.extraCommands}
          ${cfg.shell}
        '';

        bundle = pkgs.nix-bundle.nix-bootstrap {
          target = entrypoint;
          run = "/bin/entrypoint";
          nixUserChrootFlags =
            builtins.concatStringsSep " " (
              map (var: "-p ${var}") cfg.preservedEnvironmentVariables
              ++ mapAttrsToList (from: to: "-m ${from}:${to}") cfg.mappedDirectories
            );
        };
      in
      bundle.overrideAttrs (drv: {
        name = "veritas-drop-pod";
        # Override the build command to substitute `/tmp` for `cfg.unpackDirectory` - on one
        # Ubuntu machine tested, the bundle would only be partially unarchived to `/tmp`
        # but worked to other directories (`sed` is used over `substituteInPlace` as it
        # is much faster).
        buildCommand = (drv.buildCommand or "") + ''
          ${pkgs.gnused}/bin/sed -i "s#tmpdir=/tmp#tmpdir=${cfg.unpackDirectory}#" $out
        '';
      });
  };
}
