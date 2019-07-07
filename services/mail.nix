{ config, pkgs, ... }:

let
  domain = "davidtw.co";
  email = "david@${domain}";
  script = let
    name = "systemd-email";
    dir = pkgs.writeScriptBin name ''
      #! ${pkgs.runtimeShell} -e
      ${pkgs.system-sendmail}/bin/sendmail -t <<ERRMAIL
      To: $1
      From: systemd on ${config.networking.hostName} <no-reply@${domain}>
      Subject: $2
      Content-Transfer-Encoding: 8bit
      Content-Type: text/plain; charset=UTF-8

      $(${pkgs.systemd}/bin/systemctl status --full "$2")
      ERRMAIL
    '';
  in "${dir}/bin/${name}";
in {
  environment.systemPackages = with pkgs; [ mailutils ];

  networking.defaultMailServer = {
    authUser = "${email}";
    authPassFile = "${../secrets/mail.password}";
    directDelivery = true;
    domain = "${domain}";
    hostName = "smtp.fastmail.com:465";
    root = "${email}";
    setSendmail = true;
    useSTARTTLS = false;
    useTLS = true;
  };

  systemd.services."systemd-unit-status-email@" = {
    description = "Send a status email for %i";
    enable = true;
    reloadIfChanged = false;
    serviceConfig = {
      "Type" = "oneshot";
      "RemainAfterExit" = false;
      "ExecStart" = "${script} ${email} %i";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
