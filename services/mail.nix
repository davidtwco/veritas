{ config, pkgs, ... }:

let
  domain = "davidtw.co";
  email = "david@${domain}";
in {
  # Configuration {{{
  # =============
  # Configure default mail server so that cron can notify on failure.
  networking.defaultMailServer = {
    authUser = "${email}";
    # Set the permissions of this to 600!
    authPassFile = "${config.users.extraUsers.david.home}/.mailserverpassword";
    directDelivery = true;
    domain = "${domain}";
    hostName = "smtp.fastmail.com:465";
    root = "${email}";
    setSendmail = true;
    useSTARTTLS = false;
    useTLS = true;
  };
  # }}}

  # Packages {{{
  # ========
  environment.systemPackages = with pkgs; [ mailutils ];
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
