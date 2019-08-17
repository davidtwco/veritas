# Home configuration takes arguments to allow different hosts to configure some aspects of
# the configuration (ie. different git credentials for work machines, etc.).
args @ { email, name, ...  }:
{ config, pkgs, ... }:

{
  imports = [
    # Import shared configuration of overlays and nixpkgs.
    ../../config.nix
    # Import other home configurations.
    ./neovim
  ];

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
    gitAndTools.hub patchutils

    # GnuPG
    haskellPackages.hopenpgp-tools gnupg

    # Keybase
    keybase
  ];
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
      core = {
        editor = "${pkgs.neovim}/bin/nvim";
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

  # XDG {{{
  # ===
  xdg.enable = true;
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
