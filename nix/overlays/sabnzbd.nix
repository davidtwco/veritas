_: super:
let
  patch = import
    (super.fetchgit {
      url = "https://github.com/jojosch/nixpkgs.git";
      # `sabnzbd-fix` branch
      rev = "dce448995cd82806d5e02e2b836b724ba4ec700f";
      sha256 = "sha256-kolRJSmOjdaCLYgy7jX+w39luOEVdJxvT2njUoM6Krg=";
    })
    { inherit (super) system; config.allowUnfree = true; };
in
{
  inherit (patch) sabnzbd;
}
