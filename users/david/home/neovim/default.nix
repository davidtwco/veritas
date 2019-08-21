{ config, pkgs, ... }:

let
  plugins = pkgs.callPackage ./plugins.nix {};
in {
  programs.neovim = {
    configure = {
      customRC = ''
        ${builtins.readFile ./functions.vim}

        " Enable clippy if available.
        let g:ale_rust_cargo_use_clippy = '${pkgs.latest.rustChannels.stable.rust}/bin/cargo-clippy'

        " Set ALE executable paths directly to the nix store.
        let g:ale_c_clangd_executable = '${pkgs.unstable.clang-tools}/bin/clangd'
        let g:ale_cpp_clangd_executable = '${pkgs.unstable.clang-tools}/bin/clangd'

        let g:ale_c_clang_executable = '${pkgs.unstable.clang}/bin/clang'
        let g:ale_cpp_clang_executable = '${pkgs.unstable.clang}/bin/clang++'

        let g:ale_c_clangtidy_executable = '${pkgs.unstable.clang-tools}/bin/clang-tidy'
        let g:ale_cpp_clangtidy_executable = '${pkgs.unstable.clang-tools}/bin/clang-tidy'

        " ALE's C++ configuration shares the value of the C configuration for `clang-format`.
        let g:ale_c_clangformat_executable = '${pkgs.unstable.clang-tools}/bin/clang-format'

        " Change backup, swap and undo directory. If a path ends in '//' then the file name
        " is built from the entire path. No more issues between projects.
        call MaybeMkdir('${config.xdg.cacheHome}/nvim/swap/')
        set directory=${config.xdg.cacheHome}/nvim/swap//

        call MaybeMkdir('${config.xdg.cacheHome}/nvim/backup/')
        set backupdir=${config.xdg.cacheHome}/nvim/backup//

        if exists('+undofile')
          call MaybeMkdir('${config.xdg.cacheHome}/nvim/undo/')
          set undodir=${config.xdg.cacheHome}/nvim/undo//
        end

        if exists('+shada')
            " Change SHAred DAta path.
            set shada+=n${config.xdg.cacheHome}/nvim/shada
        else
            " Change viminfo path.
            set viminfo+=n${config.xdg.cacheHome}/nvim/viminfo
        endif

        " Save the `.lvimrc` persistence file in the cache folder.
        let g:localvimrc_persistence_file = '${config.xdg.cacheHome}/nvim/lvimrc_persistence'

        ${builtins.readFile ./native.vim}
        ${builtins.readFile ./plugins.vim}
        ${builtins.readFile ./completion.vim}
        ${builtins.readFile ./statusline.vim}
        ${builtins.readFile ./mappings.vim}
      '';
      packages.plugins = with plugins; {
        start = [
          # Polyglot adds a bunch of syntax handling for different languages and tools, check if
          # new languages are included before adding them manually.
          vim-polyglot
          # Rust (included in Polyglot, but explicitly disabled so that we can use newer versions).
          rust-vim
          # Other languages
          pgsql-vim vim-graphql vim-hocon vim-jinja vim-nix vim-pandoc vim-pandoc-syntax vim-puppet
          # Generate ctags for projects.
          vim-gutentags
          # Auto-adds `end` where appropriate.
          vim-endwise
          # Hybrid colour scheme
          vim-hybrid
          # Autocompletion/linting/fixing.
          ale lightline-ale
          # Add operator to comment out lines.
          vim-commentary
          # Improvements to netrw.
          vim-vinegar
          # Show git changes in the sign column
          vim-signify
          # Git wrappers
          vim-fugitive vim-rhubarb fugitive-gitlab-vim
          # Helper functions for unix commands.
          vim-eunuch
          # Easy navigation between vim splits and tmux panes.
          vim-tmux-navigator
          # Focus events and clipboard for tmux.
          vim-tmux-clipboard vim-tmux-focus-events
          # GnuPG
          vim-gnupg
          # Switch to absolute line numbers for buffers that aren't focused.
          vim-numbertoggle
          # Fuzzy file search.
          fzf fzf-vim
          # Statusline
          lightline
          # Show marks in sign column.
          vim-signature
          # Adds `s` motion for matching any two characters.
          vim-sneak
          # Improve `.` (repeat) for plugin maps.
          vim-repeat
          # Terminal utilities.
          split-term-vim
          # Handy bracket matchings.
          vim-unimpaired
          # Commands for interactig with surroundings ("", '', {}, etc).
          vim-surround
          # Move sideways left or right through argument lists, etc.
          sideways-vim
          # Apply indentation from `.editorconfig` files.
          editorconfig-vim
          # Multi-file search (`Ack`)
          ferret
          # Improved incremental search - hides search highlighting after moving cursor.
          is-vim
          # Enhanced `%` functionality.
          vim-matchit
          # Look for project specific `.lvimrc` files.
          vim-localvimrc
        ];
        opt = [
          # Activate/deactivate and list virtual environments.
          vim-virtualenv
          # Functions that interact with tmux.
          vim-tbone
          # Hide interface elements for writing.
          goyo-vim
          # Text filtering and alignment.
          tabular
          # Show current tag in statusline.
          tagbar
          # Visualize the undo tree.
          vim-mundo
          # Search/substitution/abbreviation of word variations.
          vim-abolish
          # Date manipulation commands.
          vim-speeddating
          # Access unicode character metadata.
          vim-characterize
          # Session saving.
          vim-obsession
          # Live markdown preview (needs livedown npm package).
          vim-livedown
        ];
      };
    };
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython = true;
    withPython3 = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
