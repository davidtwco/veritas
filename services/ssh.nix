{ config, pkgs, ... }:

{
  programs.mosh = {
    enable = true;
    withUtempter = true;
  };

  services.openssh = {
    enable = true;
    forwardX11 = true;
    openFirewall = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  # Don't sleep or hibernate when there are active SSH connections.
  environment.etc."ssh/sshrc" = {
    text = ''
      #!/usr/bin/env sh
      export tmp_file="/tmp/systemd-inhibit-suspend.log"
      if [ ! -z $SSH_TTY ]; then
        ${pkgs.coreutils}/bin/nohup \
          ${pkgs.systemd}/bin/systemd-inhibit --what="sleep" --who="sshd" \
          --why="No sleep due to $SSH_TTY" --mode="delay" \
          /etc/ssh/systemd_lock.sh \
          &>> "$tmp_file" &
      fi
    '';
    mode = "744";
  };

  environment.etc."ssh/systemd_lock.sh" = {
    text = ''
      #!/usr/bin/env sh
      export LANG=C
      while ${pkgs.coreutils}/bin/who | \
            ${pkgs.gnugrep}/bin/grep --quiet " $(echo $SSH_TTY | \
            ${pkgs.coreutils}/bin/cut -d "/" -f 3- ) "; do
        ${pkgs.coreutils}/bin/sleep 60
      done
    '';
    mode = "744";
    user = "david";
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
