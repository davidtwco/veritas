{ pkgs, ... }:

# Define our own plugin list with pinned versions so that we can guarantee
# a working configuration. Some plugins require `dontBuild` as they include
# `Makefile`s to run tests and build docs.

{
  ale = pkgs.vimUtils.buildVimPlugin {
    name = "ale";
    src = builtins.fetchGit {
      url = "https://github.com/dense-analysis/ale.git";
      ref = "master";
      rev = "28c93ab1854ef41a46855401cc4addbaf7dfb9d4";
    };
  };
  editorconfig-vim = pkgs.vimUtils.buildVimPlugin {
    name = "editorconfig-vim";
    src = builtins.fetchGit {
      url = "https://github.com/editorconfig/editorconfig-vim.git";
      ref = "master";
      rev = "c718cefc51ccdaf7bd27c4c1ae2de55103434241";
    };
  };
  ferret = pkgs.vimUtils.buildVimPlugin {
    name = "ferret";
    src = builtins.fetchGit {
      url = "https://github.com/wincent/ferret.git";
      ref = "master";
      rev = "aeb47b01b36021aaf84ff4f7f1a4cf64bc68fe53";
    };
  };
  fugitive-gitlab-vim = pkgs.vimUtils.buildVimPlugin {
    name = "fugitive-gitlab.vim";
    src = builtins.fetchGit {
      url = "https://github.com/shumphrey/fugitive-gitlab.vim.git";
      ref = "master";
      rev = "43a13dbbc9aae85338877329ed28c9e4d8488db1";
    };
  };
  fzf = pkgs.vimPlugins.fzfWrapper;
  fzf-vim = pkgs.vimUtils.buildVimPlugin {
    name = "fzf.vim";
    src = builtins.fetchGit {
      url = "https://github.com/junegunn/fzf.vim.git";
      ref = "master";
      rev = "359a80e3a34aacbd5257713b6a88aa085337166f";
    };
  };
  goyo-vim = pkgs.vimUtils.buildVimPlugin {
    name = "goyo.vim";
    src = builtins.fetchGit {
      url = "https://github.com/junegunn/goyo.vim.git";
      ref = "master";
      rev = "6b6ed2734084fdbb6315357ddcaecf9c8e6f143d";
    };
  };
  is-vim = pkgs.vimUtils.buildVimPlugin {
    name = "is.vim";
    src = builtins.fetchGit {
      url = "https://github.com/haya14busa/is.vim.git";
      ref = "master";
      rev = "61d5029310c69bde700b2d46a454f80859b5af17";
    };
  };
  lightline = pkgs.vimUtils.buildVimPlugin {
    name = "lightline";
    src = builtins.fetchGit {
      url = "https://github.com/itchyny/lightline.vim.git";
      ref = "master";
      rev = "09c61dc3f650eccd2c165c36db8330496321aa50";
    };
  };
  lightline-ale = pkgs.vimUtils.buildVimPlugin {
    name = "lightline-ale";
    src = builtins.fetchGit {
      url = "https://github.com/maximbaz/lightline-ale.git";
      ref = "master";
      rev = "dd59077f9537b344f7ae80f713c1e4856ec1520c";
    };
  };
  rust-vim = pkgs.vimUtils.buildVimPlugin {
    name = "rust.vim";
    src = builtins.fetchGit {
      url = "https://github.com/rust-lang/rust.vim.git";
      ref = "master";
      rev = "a49b1473eca309e5f5cf2486100d9efe23a6e4ff";
    };
  };
  pgsql-vim = pkgs.vimUtils.buildVimPlugin {
    name = "pgsql-vim";
    src = builtins.fetchGit {
      url = "https://github.com/lifepillar/pgsql.vim.git";
      ref = "master";
      rev = "f935de6621b573a100c0a80a472ceff544861b4e";
    };
  };
  sideways-vim = pkgs.vimUtils.buildVimPlugin {
    name = "sideways.vim";
    src = builtins.fetchGit {
      url = "https://github.com/AndrewRadev/sideways.vim";
      ref = "master";
      rev = "17c03c59913f76bbdede07b8f9d4a1f163d9b2f2";
    };
  };
  split-term-vim = pkgs.vimUtils.buildVimPlugin {
    name = "split-term.vim";
    src = builtins.fetchGit {
      url = "https://github.com/vimlab/split-term.vim.git";
      ref = "master";
      rev = "a4e28cab77ad07fc8a0ebb62a982768c02eb287c";
    };
  };
  tabular = pkgs.vimUtils.buildVimPlugin {
    name = "tabular";
    src = builtins.fetchGit {
      url = "https://github.com/godlygeek/tabular.git";
      ref = "master";
      rev = "339091ac4dd1f17e225fe7d57b48aff55f99b23a";
    };
  };
  tagbar = pkgs.vimUtils.buildVimPlugin {
    name = "tagbar";
    src = builtins.fetchGit {
      url = "https://github.com/majutsushi/tagbar.git";
      ref = "master";
      rev = "387bbadda98e1376ff3871aa461b1f0abd4ece70";
    };
  };
  vim-abolish = pkgs.vimUtils.buildVimPlugin {
    name = "vim-abolish";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-abolish.git";
      ref = "master";
      rev = "b95463a1cffd8fc9aff2a1ff0ae9327944948699";
    };
  };
  vim-characterize = pkgs.vimUtils.buildVimPlugin {
    name = "vim-characterize";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-characterize.git";
      ref = "master";
      rev = "c6d26e5017ab8637bac30db7448ddabfaa238cce";
    };
  };
  vim-commentary = pkgs.vimUtils.buildVimPlugin {
    name = "vim-commentary";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-commentary.git";
      ref = "master";
      rev = "141d9d32a9fb58fe474fcc89cd7221eb2dd57b3a";
    };
  };
  vim-endwise = pkgs.vimUtils.buildVimPlugin {
    name = "vim-endwise";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-endwise.git";
      ref = "master";
      rev = "f67d022169bd04d3c000f47b1c03bfcbc4209470";
    };
  };
  vim-eunuch = pkgs.vimUtils.buildVimPlugin {
    name = "vim-eunuch";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-eunuch.git";
      ref = "master";
      rev = "e066a0999e442d9d96f24ad9d203b1bd030ef72e";
    };
  };
  vim-fugitive = pkgs.vimUtils.buildVimPlugin {
    name = "vim-fugitive";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-fugitive.git";
      ref = "master";
      rev = "442d56e23cd75a336b28cf5e46bf0def8c65dff5";
    };
  };
  vim-gnupg = pkgs.vimUtils.buildVimPlugin {
    name = "vim-gnupg";
    src = builtins.fetchGit {
      url = "https://github.com/jamessan/vim-gnupg.git";
      ref = "master";
      rev = "6219a5a0d70dbc10c5e70289a2c400d6d8b62762";
    };
  };
  vim-graphql = pkgs.vimUtils.buildVimPlugin {
    name = "vim-graphql";
    src = builtins.fetchGit {
      url = "https://github.com/jparise/vim-graphql.git";
      ref = "master";
      rev = "61e342c4facd5cbc645104262e866882ea1cf5c3";
    };
    dontBuild = true;
  };
  vim-gutentags = pkgs.vimUtils.buildVimPlugin {
    name = "vim-gutentags";
    src = builtins.fetchGit {
      url = "https://github.com/ludovicchabant/vim-gutentags.git";
      ref = "master";
      rev = "eecb136fae97e30d5f01e71f0d3b775c8b017385";
    };
  };
  vim-hocon = pkgs.vimUtils.buildVimPlugin {
    name = "vim-hocon";
    src = builtins.fetchGit {
      url = "https://github.com/GEverding/vim-hocon.git";
      ref = "master";
      rev = "bb8fb14e00f8fc1eec27dd39dcc605aac43328a3";
    };
  };
  vim-hybrid = pkgs.vimUtils.buildVimPlugin {
    name = "vim-hybrid";
    src = builtins.fetchGit {
      url = "https://github.com/w0ng/vim-hybrid.git";
      ref = "master";
      rev = "cc58baabeabc7b83768e25b852bf89c34756bf90";
    };
  };
  vim-jinja = pkgs.vimUtils.buildVimPlugin {
    name = "vim-jinja";
    src = builtins.fetchGit {
      url = "https://github.com/lepture/vim-jinja.git";
      ref = "master";
      rev = "8d330a7aaf0763d080dc82204b4aaba6ac0605c6";
    };
  };
  vim-livedown = pkgs.vimUtils.buildVimPlugin {
    name = "vim-livedown";
    src = builtins.fetchGit {
      url = "https://github.com/shime/vim-livedown.git";
      ref = "master";
      rev = "24c78c0c1177c0231bb542fa1e3807a3b089248e";
    };
  };
  vim-localvimrc = pkgs.vimUtils.buildVimPlugin {
    name = "vim-localvimrc";
    src = builtins.fetchGit {
      url = "https://github.com/embear/vim-localvimrc.git";
      ref = "master";
      rev = "0b36a367f4d46b7f060836fcbfec029cce870ea9";
    };
    dontBuild = true;
  };
  vim-matchit = pkgs.vimUtils.buildVimPlugin {
    name = "vim-matchit";
    src = builtins.fetchGit {
      url = "https://github.com/geoffharcourt/vim-matchit.git";
      ref = "master";
      rev = "44267b436d3d73c8adfb23537a1b86862239ad12";
    };
  };
  vim-mundo = pkgs.vimUtils.buildVimPlugin {
    name = "vim-mundo";
    src = builtins.fetchGit {
      url = "https://github.com/simnalamburt/vim-mundo.git";
      ref = "master";
      rev = "a32f8af11dee435a198bef3504f0aa594f960409";
    };
  };
  vim-nix = pkgs.vimUtils.buildVimPlugin {
    name = "vim-nix";
    src = builtins.fetchGit {
      url = "https://github.com/LnL7/vim-nix.git";
      ref = "master";
      rev = "a3eed01f4de995a51dfdd06287e44fcb231f6adf";
    };
  };
  vim-numbertoggle = pkgs.vimUtils.buildVimPlugin {
    name = "vim-numbertoggle";
    src = builtins.fetchGit {
      url = "https://github.com/jeffkreeftmeijer/vim-numbertoggle.git";
      ref = "master";
      rev = "cfaecb9e22b45373bb4940010ce63a89073f6d8b";
    };
  };
  vim-obsession = pkgs.vimUtils.buildVimPlugin {
    name = "vim-obsession";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-obsession.git";
      ref = "master";
      rev = "60f0ef80fd74b8c58fd0cc7a55b81846e06c04f3";
    };
  };
  vim-pandoc = pkgs.vimUtils.buildVimPlugin {
    name = "vim-pandoc";
    src = builtins.fetchGit {
      url = "https://github.com/vim-pandoc/vim-pandoc.git";
      ref = "master";
      rev = "b41a18b75dd8dee5217bca9f68d91f8fd2ea6084";
    };
  };
  vim-pandoc-syntax = pkgs.vimUtils.buildVimPlugin {
    name = "vim-pandoc-syntax";
    src = builtins.fetchGit {
      url = "https://github.com/vim-pandoc/vim-pandoc-syntax.git";
      ref = "master";
      rev = "6710d46c8b772f77248f30d650c83f90c68f37ab";
    };
  };
  vim-polyglot = pkgs.vimUtils.buildVimPlugin {
    name = "vim-polyglot";
    src = builtins.fetchGit {
      url = "https://github.com/sheerun/vim-polyglot.git";
      ref = "master";
      rev = "3ddca5da461ebfaa82104f82e3cbf19d1c326ade";
    };
  };
  vim-puppet = pkgs.vimUtils.buildVimPlugin {
    name = "vim-puppet";
    src = builtins.fetchGit {
      url = "https://github.com/rodjek/vim-puppet.git";
      ref = "master";
      rev = "b2ae19b3ef397ed7404bf15051cbc5ff655b893e";
    };
  };
  vim-repeat = pkgs.vimUtils.buildVimPlugin {
    name = "vim-repeat";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-repeat.git";
      ref = "master";
      rev = "ae361bea990e27d5beade3a8d9fa22e25cec3100";
    };
  };
  vim-rhubarb = pkgs.vimUtils.buildVimPlugin {
    name = "vim-rhubarb";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-rhubarb.git";
      ref = "master";
      rev = "c509c7eedeea641f5b0bdae708581ff610fbff5b";
    };
  };
  vim-signature = pkgs.vimUtils.buildVimPlugin {
    name = "vim-signature";
    src = builtins.fetchGit {
      url = "https://github.com/kshenoy/vim-signature.git";
      ref = "master";
      rev = "6bc3dd1294a22e897f0dcf8dd72b85f350e306bc";
    };
  };
  vim-signify = pkgs.vimUtils.buildVimPlugin {
    name = "vim-signify";
    src = builtins.fetchGit {
      url = "https://github.com/mhinz/vim-signify.git";
      ref = "master";
      rev = "ffab0c9d71bf33529b3dd52783b45652e8b500ad";
    };
  };
  vim-sleuth = pkgs.vimUtils.buildVimPlugin {
    name = "vim-sleuth";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-sleuth.git";
      ref = "master";
      rev = "7a104e34c10c6f3581c6e98da7834d765d0b067c";
    };
  };
  vim-sneak = pkgs.vimUtils.buildVimPlugin {
    name = "vim-sneak";
    src = builtins.fetchGit {
      url = "https://github.com/justinmk/vim-sneak.git";
      ref = "master";
      rev = "5b670df36291ca75f5ded5cd7608948d58ff6325";
    };
    dontBuild = true;
  };
  vim-speeddating = pkgs.vimUtils.buildVimPlugin {
    name = "vim-speeddating";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-speeddating.git";
      ref = "master";
      rev = "ce2f1aae9f2be128b4ca322a8e797be3ae40c30b";
    };
  };
  vim-surround = pkgs.vimUtils.buildVimPlugin {
    name = "vim-surround";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-surround.git";
      ref = "master";
      rev = "fab8621670f71637e9960003af28365129b1dfd0";
    };
  };
  vim-tbone = pkgs.vimUtils.buildVimPlugin {
    name = "vim-tbone";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-tbone.git";
      ref = "master";
      rev = "b7f41b10db9ed5e5854fc5fe3a619bc05f2d541a";
    };
  };
  vim-tmux-clipboard = pkgs.vimUtils.buildVimPlugin {
    name = "vim-tmux-clipboard";
    src = builtins.fetchGit {
      url = "https://github.com/roxma/vim-tmux-clipboard.git";
      ref = "master";
      rev = "47187740b88f9dab213f44678800cc797223808e";
    };
  };
  vim-tmux-focus-events = pkgs.vimUtils.buildVimPlugin {
    name = "vim-tmux-focus-events";
    src = builtins.fetchGit {
      url = "https://github.com/tmux-plugins/vim-tmux-focus-events.git";
      ref = "master";
      rev = "0f89b1ada151e22882a5a47a1ee2b6d6135bc5c1";
    };
  };
  vim-tmux-navigator = pkgs.vimUtils.buildVimPlugin {
    name = "vim-tmux-navigator";
    src = builtins.fetchGit {
      url = "https://github.com/christoomey/vim-tmux-navigator.git";
      ref = "master";
      rev = "4e1a877f51a17a961b8c2a285ee80aebf05ccf42";
    };
  };
  vim-unimpaired = pkgs.vimUtils.buildVimPlugin {
    name = "vim-unimpaired";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-unimpaired.git";
      ref = "master";
      rev = "ab7082c0e89df594a5ba111e18af17b3377d216d";
    };
  };
  vim-vinegar = pkgs.vimUtils.buildVimPlugin {
    name = "vim-vinegar";
    src = builtins.fetchGit {
      url = "https://github.com/tpope/vim-vinegar.git";
      ref = "master";
      rev = "09ac84c4d152a944caa341e913220087211c72ef";
    };
  };
  vim-virtualenv = pkgs.vimUtils.buildVimPlugin {
    name = "vim-virtualenv";
    src = builtins.fetchGit {
      url = "https://github.com/plytophogy/vim-virtualenv.git";
      ref = "master";
      rev = "85b14c7e3f7f0f0ea9cf2c7e010f4c1b44e9eaf1";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
