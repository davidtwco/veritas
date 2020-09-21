_: super:
let
  patch = import
    (super.fetchgit {
      url = "https://github.com/Magicloud/nixpkgs.git";
      # `vbox6114` branch
      rev = "e1538e43b92c19465df62f3178c9262690b76c3b";
      sha256 = "sha256-tgl1or1E2KDFEynmT0+Uqfvjd03zS1AcjjCX3fM9AQ8=";
    })
    { inherit (super) system; };
in
{
  inherit (patch) virtualbox;
}
