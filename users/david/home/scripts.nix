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
    (
      writeScriptBin "list-iommu-groups" ''
        #! ${pkgs.runtimeShell} -e
        shopt -s nullglob
        for g in /sys/kernel/iommu_groups/*; do
          echo "IOMMU Group ''${g##*/}:"
          for d in $g/devices/*; do
            echo -e "\t$(lspci -nns ''${d##*/})"
          done;
        done;
      ''
    )
    (
      writeScriptBin "print-fish-colours" ''
        #! ${pkgs.unstable.fish}/bin/fish
        set -l clr_list (set -n | grep fish | grep color | grep -v __)
        if test -n "$clr_list"
          set -l bclr (set_color normal)
          set -l bold (set_color --bold)
          printf "\n| %-35s | %-35s |\n" Variable Definition
          echo '|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|'
          for var in $clr_list
            set -l def $$var
            set -l clr (set_color $def ^/dev/null)
            or begin
              printf "| %-35s | %s%-35s$bclr |\n" "$var" (set_color --bold white --background=red) "$def"
              continue
            end
            printf "| $clr%-35s$bclr | $bold%-35s$bclr |\n" "$var" "$def"
          end
          echo '|_____________________________________|_____________________________________|'\n
        end
      ''
    )
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
