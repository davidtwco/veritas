{ lib, buildVimPlugin, fetchFromGitHub }:

buildVimPlugin {
  name = "fluent-vim";

  src = fetchFromGitHub {
    owner = "projectfluent";
    repo = "fluent.vim";
    rev = "2278e05ec7fbb48e06b5d26319385e1c09325760";
    sha256 = "0hp8jjr4xpw73pkfpbxpjnr49cvjyksymvj748zaxjznkvizmyxc";
  };

  meta = with lib; {
    description = "Fluent Syntax Highlighting for vim/neovim";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}
