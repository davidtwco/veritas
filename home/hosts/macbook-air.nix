{ config, pkgs, ... }:

let
  itermIntegration = pkgs.fetchurl {
    url = "https://iterm2.com/shell_integration/fish";
    sha256 = "sha256-tdn4z0tIc0nC5nApGwT7GYbiY91OTA4hNXZDDQ6g9qU=";
  };
in
{
  home.stateVersion = "23.05";

  programs = {
    fish = {
      interactiveShellInit = ''
        # Add Homebrew environment variables - not currently managed by Nix.
        if status --is-interactive
          eval (/opt/homebrew/bin/brew shellenv)
        end

        # Add Nix to the environment.
        if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
          source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        end

        # Integrate with iTerm2
        source ${itermIntegration}

        # Set `SHELL` to current shell's path - iTerm2 doesn't set it.
        set -gx SHELL (status fish-path)
      '';
      shellAliases = {
        "tailscale" = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      };
    };

    git = {
      iniContent.gpg = {
        format = "ssh";
        ssh = {
          program = config.programs.git.signing.gpgPath;
          allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
        };
      };
      signing = {
        key = builtins.readFile ../data/ssh-david-1password-github-id_ed25519.pub;
        signByDefault = true;
        gpgPath = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };

    ssh.extraConfig = ''
      IdentityAgent "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
}
