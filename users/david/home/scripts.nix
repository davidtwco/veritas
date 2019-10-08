{ pkgs, ... }:

# This file contains short shell scripts that are included in the dotfiles.

{
  home.packages = with pkgs; [
    (
      writeScriptBin "gpg-backup-to-paper" ''
        #! ${runtimeShell} -e
        # Provide the path to the secret key as the first argument.
        NAME="$(${coreutils}/bin/basename $1 | ${coreutils}/bin/cut -d. -f1)"
        ${paperkey}/bin/paperkey --secret-key $1 --output-type raw | \
          ${coreutils}/bin/split -b 1500 - $NAME-
        for K in $NAME-*; do
            ${dmtx-utils}/bin/dmtxwrite -e 8 $K > $K.png
        done
      ''
    )
    (
      writeScriptBin "gpg-restore-to-paper" ''
        #! ${pkgs.runtimeShell} -e
        # Pipe the datamatrix files concatenated. Provide the public key as the first argument and
        # filename as second argument.
        ${paperkey}/bin/paperkey --pubring $1 <&0 > $2.gpg
      ''
    )
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
