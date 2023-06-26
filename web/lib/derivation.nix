{ pkgs, lib, site, system }:

{
  # Using a simpler `mkDerivation` than `stdenv.mkDerivation` is faster.
  mkDerivation = { name, command, inputs ? [ ] }:
    let
      scriptName = "site-${name}-builder";
      script = pkgs.writeScriptBin scriptName ''
        #! ${pkgs.runtimeShell} -e
        ${command}
      '';
    in
    derivation {
      inherit system;
      name = "site-${name}";

      out = placeholder "out";
      builder = "${pkgs.bash}/bin/bash";

      allowSubstitutes = false;
      preferLocalBuild = true;

      PATH = lib.makeBinPath (inputs ++ [ pkgs.coreutils ]);

      args = [ "-e" "${script}/bin/${scriptName}" ];
    } // (lib.optionalAttrs (pkgs.stdenv.isLinux) {
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      LC_ALL = "en_GB.UTF-8";
    });
}
