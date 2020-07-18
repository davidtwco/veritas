{
  description = ''
    Veritas is the personal mono-repo of David Wood; containing the declarative configuration of
    servers, desktops and laptops - including dotfiles; a collection of packages; a static site
    generator and source of "davidtw.co".
  '';

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "master";
    };

    home-manager = {
      type = "github";
      owner = "rycee";
      repo = "home-manager";
      ref = "bqv-flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-mozilla = {
      type = "github";
      owner = "mozilla";
      repo = "nixpkgs-mozilla";
      ref = "master";
      flake = false;
    };

    gitignore-nix = {
      type = "github";
      owner = "hercules-ci";
      repo = "gitignore.nix";
      ref = "master";
      flake = false;
    };

    neuron = {
      type = "github";
      owner = "srid";
      repo = "neuron";
      ref = "master";
      flake = false;
    };
  };

  outputs = { self, ... } @ inputs:
    with inputs.nixpkgs.lib;
    let
      forEachSystem = genAttrs [ "x86_64-linux" "aarch64-linux" ];
      pkgsBySystem = forEachSystem (system:
        import inputs.nixpkgs {
          inherit system;
          config = import ./nix/config.nix;
          overlays = self.internal.overlays."${system}";
        }
      );

      mkNixOsConfiguration = name: { system, config }:
        nameValuePair name (nixosSystem {
          inherit system;
          modules = [
            ({ name, ... }: {
              # Set the hostname to the name of the configuration being applied (since the
              # configuration being applied is determined by the hostname).
              networking.hostName = name;
            })
            ({ inputs, ... }: {
              # Use the nixpkgs from the flake.
              nixpkgs = { pkgs = pkgsBySystem."${system}"; };

              # For compatibility with nix-shell, nix-build, etc.
              environment.etc.nixpkgs.source = inputs.nixpkgs;
              nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];
            })
            ({ pkgs, ... }: {
              # Don't rely on the configuration to enable a flake-compatible version of Nix.
              nix = {
                package = pkgs.nixFlakes;
                extraOptions = "experimental-features = nix-command flakes";
              };
            })
            ({ inputs, ... }: {
              # Re-expose self and nixpkgs as flakes.
              nix.registry = {
                self.flake = inputs.self;
                nixpkgs = {
                  from = { id = "nixpkgs"; type = "indirect"; };
                  flake = inputs.nixpkgs;
                };
              };
            })
            (import ./nixos/configs)
            (import ./nixos/modules)
            (import ./nixos/profiles)
            (import config)
          ];
          specialArgs = { inherit name inputs; };
        });

      mkHomeManagerConfiguration = name: { system, config }:
        nameValuePair name ({ ... }: {
          imports = [
            (import ./home/configs)
            (import ./home/modules)
            (import ./home/profiles)
            (import config)
          ];

          # For compatibility with nix-shell, nix-build, etc.
          home.file.".nixpkgs".source = inputs.nixpkgs;
          systemd.user.sessionVariables."NIX_PATH" =
            mkForce "nixpkgs=$HOME/.nixpkgs\${NIX_PATH:+:}$NIX_PATH";

          # Use the same Nix configuration throughout the system.
          xdg.configFile."nixpkgs/config.nix".source = ./nix/config.nix;

          # Re-expose self and nixpkgs as flakes.
          xdg.configFile."nix/registry.json".text = builtins.toJSON {
            version = 2;
            flakes =
              let
                toInput = input:
                  {
                    type = "path";
                    path = input.outPath;
                  } // (
                    filterAttrs
                      (n: _: n == "lastModified" || n == "rev" || n == "revCount" || n == "narHash")
                      input
                  );
              in
              [
                {
                  from = { id = "self"; type = "indirect"; };
                  to = toInput inputs.self;
                }
                {
                  from = { id = "nixpkgs"; type = "indirect"; };
                  to = toInput inputs.nixpkgs;
                }
              ];
          };
        });

      mkHomeManagerHostConfiguration = name: { system }:
        nameValuePair name (inputs.home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = { ... }: {
            imports = [ self.internal.homeManagerConfigurations."${name}" ];

            xdg.configFile."nix/nix.conf".text =
              let
                nixConf = import ./nix/conf.nix;
                substituters = [ "https://cache.nixos.org" ] ++ nixConf.binaryCaches;
                trustedPublicKeys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                ] ++ nixConf.binaryCachePublicKeys;
              in
              ''
                substituters = ${builtins.concatStringSep " " substituters}
                trusted-public-keys = ${builtins.concatStringSep " " trustedPublicKeys}
              '';

            nixpkgs = {
              config = import ./nix/config.nix;
              overlays = self.internal.overlays."${system}";
            };
          };
          homeDirectory = "/home/david";
          pkgs = pkgsBySystem."${system}";
          username = "david";
        });
    in
    {
      # `internal` isn't a known output attribute for flakes. It is used here to contain
      # anything that isn't meant to be re-usable.
      internal = {
        # Expose the development shells defined in the repository, run these with:
        #
        #   nix dev-shell 'self#devShells.x86_64-linux.rustc'
        devShells = forEachSystem (system:
          let
            pkgs = pkgsBySystem."${system}";
          in
          {
            cargo = import ./nix/shells/cargo.nix { inherit pkgs; };
            generic-nightly-rust = import ./nix/shells/generic-nightly-rust.nix { inherit pkgs; };
            llvm-clang = import ./nix/shells/llvm-clang.nix { inherit pkgs; };
            rustc = import ./nix/shells/rustc.nix { inherit pkgs; };
            rustc-perf = import ./nix/shells/rustc-perf.nix { inherit pkgs; };
            zulip = import ./nix/shells/zulip.nix { inherit pkgs; };
          }
        );

        # Attribute set of hostnames to home-manager modules with the entire configuration for
        # that host - consumed by the home-manager NixOS module for that host (if it exists)
        # or by `mkHomeManagerHostConfiguration` for home-manager-only hosts.
        homeManagerConfigurations = mapAttrs' mkHomeManagerConfiguration {
          dtw-campaglia = { system = "x86_64-linux"; config = ./home/hosts/campaglia.nix; };

          dtw-jar-keurog = { system = "x86_64-linux"; config = ./home/hosts/jar-keurog.nix; };

          dtw-volkov = { system = "x86_64-linux"; config = ./home/hosts/volkov.nix; };
        };

        # Overlays consumed by the home-manager/NixOS configuration.
        overlays = forEachSystem (system: [
          (self.overlay."${system}")
          (import inputs.nixpkgs-mozilla)
          (_: _: import inputs.gitignore-nix { lib = inputs.nixpkgs.lib; })
          (_: _: { neuron-zettelkasten = import inputs.neuron { inherit system; }; })
          (import ./nix/overlays/iosevka.nix)
          (import ./nix/overlays/vaapi.nix)
        ] ++ optionals (system == "x86_64-linux") [
          (import ./nix/overlays/plex.nix)
        ]);

        # Expose the static site generator as a re-usable library of sorts - it definitely isn't
        # a recognized output by Nix and there's no stability guarantees.
        staticSiteGenerator = forEachSystem (system:
          import ./web/lib { inherit system; pkgs = pkgsBySystem."${system}"; }
        );

        # Expose any websites built by the static site generator as outputs too.
        staticSites = forEachSystem (system:
          let
            pkgs = pkgsBySystem."${system}";
            site = self.internal.staticSiteGenerator."${system}";
          in
          {
            "davidtwco" = import ./web/src { inherit pkgs site; };
          }
        );
      };

      # Attribute set of hostnames to evaluated NixOS configurations. Consumed by `nixos-rebuild`
      # on those hosts.
      nixosConfigurations = mapAttrs' mkNixOsConfiguration {
        dtw-campaglia = { system = "x86_64-linux"; config = ./nixos/hosts/campaglia.nix; };

        dtw-jar-keurog = { system = "x86_64-linux"; config = ./nixos/hosts/jar-keurog.nix; };

        dtw-volkov = { system = "x86_64-linux"; config = ./nixos/hosts/volkov.nix; };
      };

      # Import the modules exported by this flake. Explicitly don't expose profiles in
      # `nixos/configs` and `nixos/profiles` - these are only used for internal organization
      # of my configurations.
      #
      # These are only used by other projects that might import this flake.
      nixosModules = {
        nixopsDns = import ./nixos/modules/nixops-dns.nix;
        perUserVpn = import ./nixos/modules/per-user-vpn.nix;
      };

      # Expose a dev shell which contains tools for working on this repository.
      devShell = forEachSystem (system:
        with pkgsBySystem."${system}";

        mkShell {
          name = "veritas";
          buildInputs = [
            git-crypt
            neuron-zettelkasten
          ];
        }
      );

      # Expose an overlay which provides the packages defined by this repository.
      #
      # Overlays are used more widely in this repository, but often for modifying upstream packages
      # or making third-party packages easier to access - it doesn't make sense to share those,
      # so they in the flake output `internal.overlays`.
      #
      # These are meant to be consumed by other projects that might import this flake.
      overlay = forEachSystem (system: _: _: self.packages."${system}");

      # Expose the packages defined in this flake, built for any supported systems. These are
      # meant to be consumed by other projects that might import this flake.
      packages = forEachSystem (system:
        let
          pkgs = pkgsBySystem."${system}";
        in
        {
          cargo-bisect-rustc = pkgs.callPackage ./nix/packages/cargo-bisect-rustc { };

          measureme = pkgs.callPackage ./nix/packages/measureme { };

          rustfilt = pkgs.callPackage ./nix/packages/rustfilt.nix { };

          rustup-toolchain-install-master =
            pkgs.callPackage ./nix/packages/rustup-toolchain-install-master.nix { };

          tera-template = pkgs.callPackage ./nix/packages/tera-template { };

          neuron-veritas-vim = pkgs.callPackage ./nix/packages/neuron-veritas-vim {
            inherit (pkgs.vimUtils) buildVimPlugin;
          };
        } // optionalAttrs (system == "x86_64-linux") {
          intel-openclrt = pkgs.callPackage ./nix/packages/intel-openclrt.nix { };
        }
      );

      defaultPackage.x86_64-linux = self.internal.staticSites.x86_64-linux."davidtwco";
    };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
