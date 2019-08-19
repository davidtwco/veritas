# Home configuration takes arguments to allow different hosts to configure some aspects of
# the configuration (ie. different git credentials for work machines, etc.).
args @ { email, name, headless, ...  }:
{ config, pkgs, ... }:

let
  external = import ../../shared/external.nix;
in {
  imports = with external; [
    # Import shared configuration of overlays and nixpkgs.
    ../../shared
    # Import other home configurations.
    ./alacritty.nix
    ./neovim
    ./tmux.nix
    ./zsh
    # Import modules from unstable home-manager.
    "${homeManagerUnstable}/modules/programs/gpg.nix"
  ];

  # Apply same configuration outside of home-manager.
  xdg.configFile."nixpkgs/config.nix".source = ../../shared/config.nix;

  home.keyboard.layout = "uk";
  home.language.base = "en_GB.UTF-8";
  home.sessionVariables = {
    # Use NeoVim as editor.
    "EDITOR" = "${pkgs.neovim}/bin/nvim";
    # Use a 256-colour terminal.
    "TERM" = "xterm-256color";
    # Allow Vagrant to access Windows outside of WSL.
    "VAGRANT_WSL_ENABLE_WINDOWS_ACCESS" = "1";
    # Don't clear the screen when leaving man.
    "MANPAGER" = "less -X";
    # Enable persistent REPL history for node.
    "NODE_REPL_HISTORY" = "${config.xdg.cacheHome}/node/history";
    # Use sloppy mode by default, matching web browsers.
    "NODE_REPL_MODE" = "sloppy";
    # Configure fzf to use ripgrep.
    "FZF_DEFAULT_COMMAND" =
      "${pkgs.ripgrep}/bin/rg --files --hidden --follow -g \"!{.git}\" 2>/dev/null";
    "FZF_CTRL_T_COMMAND" = config.home.sessionVariables."FZF_DEFAULT_COMMAND";
    "FZF_DEFAULT_OPTS" = "";
  };

  # Packages {{{
  # ========
  home.packages = with pkgs; [
    # General utilities
    file which hyperfine tokei cron direnv moreutils wget bc pkgconfig idutils keepassxc

    # NixOS utilities
    nix-prefetch-scripts nix-index lorri nixfmt nix-review

    # Archiving
    unzip zip unrar p7zip dtrx

    # Processes/debugging/monitoring
    htop iotop powertop ltrace strace binutils lshw linuxPackages.perf pciutils psmisc
    pmutils dmidecode usbutils

    # Networking
    inetutils mosh bmon bind conntrack-tools tcpdump ethtool linuxPackages.bpftrace

    # Disks
    parted exfat dosfstools ncdu smartmontools

    # Man pages
    man man-pages posix_man_pages stdman

    # Dotfiles
    yadm antibody fasd pinentry_ncurses tmux universal-ctags ripgrep exa neofetch

    # Version Control
    gitAndTools.hub gitAndTools.git-imerge patchutils

    # GnuPG
    haskellPackages.hopenpgp-tools gnupg

    # Keybase
    keybase
  ];
  # }}}

  # bash {{{
  # ====
  # bash isn't used, so just make sure there's a sane minimal configuration in place.
  programs.bash.enable = true;
  # }}}

  # direnv {{{
  # ======
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
  # }}}

  # eyaml {{{
  # =====
  home.file.".eyaml/config.yaml".text = ''
    ---
    pkcs7_private_key: './keys/eyaml/private_key.pkcs7.pem'
    pkcs7_public_key: './keys/eyaml/public_key.pkcs7.pem'
  '';
  # }}}

  # fzf {{{
  # ===
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  # }}}

  # htop {{{
  # ====
  programs.htop = {
    enable = true;
    detailedCpuTime = true;
    showThreadNames = true;
    treeView = true;
  };
  # }}}

  # Git {{{
  # ===
  xdg.dataFile."git/template" = {
    text = ''


      # Always `--signoff` commits.
      Signed-off-by: ${name} <${email}>
    '';
  };

  programs.git = {
    aliases = {
      # Debug a command or alias - preceed it with `debug`.
      debug = "!set -x; GIT_TRACE=2 GIT_CURL_VERBOSE=2 GIT_TRACE_PERFORMANCE=2 GIT_TRACE_PACK_ACCESS=2 GIT_TRACE_PACKET=2 GIT_TRACE_PACKFILE=2 GIT_TRACE_SETUP=2 GIT_TRACE_SHALLOW=2 git";
      # Quote / unquote a sh command, converting it to / from a git alias string
      quote-string = "!read -r l; printf \\\"!; printf %s \"$l\" | sed 's/\\([\\\"]\\)/\\\\\\1/g'; printf \" #\\\"\\n\" #";
      quote-string-undo = "!read -r l; printf %s \"$l\" | sed 's/\\\\\\([\\\"]\\)/\\1/g'; printf \"\\n\" #";
      # Push commits upstream.
      ps = "push";
      # Overrides gitalias.txt `save` to include untracked files.
      save = "stash save --include-untracked";
    };
    enable = true;
    extraConfig = {
      color = {
        ui = "auto";
      };
      commit = {
        verbose = true;
        template = "${config.xdg.dataHome}/git/template";
      };
      diff = {
        compactionHeuristic = true;
        indentHeuristic = true;
      };
      push = {
        default = "simple";
        followTags = true;
      };
      status = {
        showStash = true;
      };
      stash = {
        showPatch = true;
      };
      submodule = {
        fetchJobs = 4;
      };
      rebase = {
        autosquash = true;
      };
      user = {
        useConfigOnly = true;
      };
    };
    ignores = [
      # Compiled source
      "*.com" "*.class" "*.dll" "*.exe" "*.o" "*.so"

      # OS generated files
      ".DS_Store" ".DS_Store?" "._*" ".Spotlight-V100" ".Trashes" "ehthumbs.db" "Thumbs.db"

      # ctags
      "tags" "tags.temp" "tags.lock" "tags.files"

      # Vim
      ".lvimrc" "Session.vim"

      # GDB
      ".gdb_history"

      # Workman
      ".workman_active_working_directory" ".workman_do_not_assign" ".workman_needs_refresh"

      # Ripgrep
      ".rgignore"

      # C/C++
      "compile_commands.json"
    ];
    includes = let
      aliases = builtins.fetchGit {
        url = "https://github.com/GitAlias/gitalias.git";
        ref = "master";
        rev = "04410eab725ef152e1eb70a87cb6fd4f52f7b4ea";
      };
    in [ { path = "${aliases}/gitalias.txt"; } ];
    lfs = {
      enable = true;
      skipSmudge = false;
    };
    package = pkgs.gitAndTools.gitFull;
    signing = {
      key = "9F53F154";
      signByDefault = true;
    };
    userEmail = args.email;
    userName = args.name;
  };
  # }}}

  # GnuPG {{{
  # =====
  # Don't use `programs.gpg` or `services.gpg-agent` until we can find a way to make them work
  # with agent forwarding.
  home.file.".gnupg/gpg.conf".text = ''
    default-key 9F53F154

    # Disable inclusion of the version string in ASCII armored output.
    no-emit-version

    # Use armoured output.
    armor

    # Disable comment string in clear text signatures and ASCII armored messages.
    no-comments

    # Display long key IDs.
    keyid-format 0xlong

    # List all keys (or the specified ones) along with their fingerprints.
    with-fingerprint

    # Display the calculated validity of user IDs during key listings.
    list-options show-uid-validity
    verify-options show-uid-validity

    # Try to use the GnuPG-Agent. With this option, GnuPG first tries to connect to
    # the agent before it asks for a passphrase.
    use-agent

    # Use unicode.
    charset utf-8

    # Cross-certify subkeys are present and valid.
    require-cross-certification

    # Disable caching of passphrase for symmetrical operations.
    no-symkey-cache

    # Disable putting recipient key IDs into messages.
    throw-keyids

    # This is the server that --recv-keys, --send-keys, and --search-keys will
    # communicate with to receive keys from, send keys to, and search for keys on.
    keyserver hkps://hkps.pool.sks-keyservers.net

    # When using --refresh-keys, if the key in question has a preferred keyserver
    # URL, then disable use of that preferred keyserver to refresh the key from.
    keyserver-options no-honor-keyserver-url

    # When searching for a key with --search-keys, include keys that are marked on
    # the keyserver as revoked.
    keyserver-options include-revoked

    # List of personal digest preferences. When multiple digests are supported by
    # all recipients, choose the strongest one.
    personal-cipher-preferences AES256 AES192 AES

    # List of personal digest preferences. When multiple ciphers are supported by
    # all recipients, choose the strongest one.
    personal-digest-preferences SHA512 SHA384 SHA256

    # Use ZLIB, BZIP2, ZIP, or no compression.
    personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed

    # Message digest algorithm used when signing a key.
    cert-digest-algo SHA512

    # SHA512 as digest for symmetric operations.
    s2k-digest-algo SHA512

    # AES256 as cipher for symmetric operations.
    s2k-cipher-algo AES256

    # This preference list is used for new keys and becomes the default for
    # "setpref" in the edit menu.
    default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
  '';

  home.file.".gnupg/gpg-agent.conf".text = let
    pinentry = "${pkgs.pinentry}/bin/" + (if headless then "pinentry-tty" else "pinentry-gnome3");
  in ''
    # Wait an hour before prompting again, always
    # prompt if it has been 2 hours, regardless most
    # recent use.
    default-cache-ttl 600
    max-cache-ttl 7200

    # Don't prompt for ssh. This is primarily so that
    # async repository checks by prompts don't trigger
    # random pinentry prompts.
    default-cache-ttl-ssh 600
    max-cache-ttl-ssh 7200

    # Act as an SSH agent.
    enable-ssh-support

    # Use different pinentry script depending on what is available.
    # Redirect through a script so this works on all distros.
    pinentry-program ${pinentry}

    # Enable logging to a socket for debugging.
    # `watchgnupg --time-only --force ${config.home.homeDirectory}/.gnupg/S.log`
    # verbose
    # debug-level guru
    # log-file socket:///${config.home.homeDirectory}/.gnupg/S.log
  '';
  # }}}

  # inputrc {{{
  # =======
  home.file.".inputrc".text = ''
    # Fix bindings for beginning of line and end of line on some machines
    "OH": beginning-of-line
    "[1~": beginning-of-line
    "[2~": beginning-of-line
    "OF": end-of-line
    "[3~": end-of-line
    "[4~": end-of-line

    # Use the text that has already been typed as the prefix for searching through
    # commands (basically more intelligent Up/Down behavior)
    "\e[A": history-search-backward
    "\e[B": history-search-forward

    # Use Alt/Meta + Delete to delete the preceding word
    "\e[3;3~": kill-word

    # Perform file completion in a case insensitive fashion
    set completion-ignore-case on

    # Treat hyphens and underscores as equivalent
    set completion-map-case on

    # Display matches for ambiguous patterns at first tab press
    set show-all-if-ambiguous on

    # Immediately add a trailing slash when autocompleting symlinks to directories
    set mark-symlinked-directories on

    # Do not autocomplete hidden files unless the pattern explicitly begins with a dot
    set match-hidden-files off

    # Show all autocomplete results at once
    set page-completions off

    # If there are more than 200 possible completions for a word, ask to show them all
    set completion-query-items 200

    # Show extra file information when completing, like `ls -F` does
    set visible-stats on

    # Be more intelligent when autocompleting by also looking at the text after
    # the cursor. For example, when the current line is "cd ~/src/mozil", and
    # the cursor is on the "z", pressing Tab will not autocomplete it to "cd
    # ~/src/mozillail", but to "cd ~/src/mozilla". (This is supported by the
    # Readline used by Bash 4.)
    set skip-completed-text on

    # Allow UTF-8 input and output, instead of showing stuff like $'\0123\0456'
    set input-meta on
    set output-meta on
    set convert-meta off

    # Set timeout for key sequences.
    set keyseq-timeout 50
  '';
  # }}}

  # less {{{
  # ====
  # Allow scrolling left and right with `h` and `l` in `less`.
  home.file.".lesskey".text = ''
    h left-scroll
    l right-scroll
  '';
  # }}}

  # Mail {{{
  # ====
  home.file.".forward".text = args.email;
  # }}}

  # XDG {{{
  # ===
  xdg.enable = true;
  # }}}

  # Xresources {{{
  # ==========
  xresources.properties = {
    # Hybrid colour scheme.
    "*background" = "#1C1C1C";
    "*foreground" = "#C5C8C6";
    "*cursorColor" = "#C5C8C6";
    "*color0" = "#282A2E";
    "*color1" = "#A54242";
    "*color2" = "#8C9440";
    "*color3" = "#DE935F";
    "*color4" = "#5F819D";
    "*color5" = "#85678F";
    "*color6" = "#5E8D87";
    "*color7" = "#707880";
    "*color8" = "#373B41";
    "*color9" = "#CC6666";
    "*color10" = "#B5BD68";
    "*color11" = "#F0C674";
    "*color12" = "#81A2BE";
    "*color13" = "#B294BB";
    "*color14" = "#8ABEB7";
    "*color15" = "#C5C8C6";
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
