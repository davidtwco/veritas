{ stdenv, buildVimPlugin }:

buildVimPlugin {
  name = "neuron-veritas-vim";

  src = ./.;

  meta = with stdenv.lib; {
    description = "Create, search and insert links to a Neuron Zettelkasten";
    license = with licenses; [ mit asl20 ];
    maintainers = with maintainers; [ davidtwco ];
    platforms = platforms.all;
  };
}
