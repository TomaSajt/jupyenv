{
  description = "declarative and reproducible Jupyter environments - powered by Nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:/teto/flake-compat/support-packages";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    ihaskell.url = "github:gibiansky/IHaskell";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , ihaskell
    , flake-utils
    , ...
    }:
    (flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ]
      (system:
      let
        pkgs = import nixpkgs
          {
            inherit system;
            allowUnsupportedSystem = true;
            overlays = nixpkgs.lib.attrValues self.overlays;
            # [ self.overlays.jupyterWith ];
          };
        ihaskellOverlay = ihaskell.packages.${system}.ihaskell-env.ihaskellOverlay;

      in
      {

        packages.default = (pkgs.jupyterlabWith {
          kernels = [ (pkgs.jupyterWith.kernels.dyalogKernel { name = "dyalog-kernel"; }) ];
        });

      })
    ) //
    {
      overlays = {
        jupyterWith = final: prev: rec {
          jupyterWith = final.callPackage ./. { };

          inherit (jupyterWith)
            jupyterlabWith
            kernels
            mkBuildExtension
            mkDirectoryWith
            mkDirectoryFromLockFile
            mkDockerImage
            ;
        };

        # haskell = import ./nix/haskell-overlay.nix;
        haskell = final: prev: {
          haskellPackages = prev.haskellPackages.override (old: {
            overrides =
              prev.lib.composeExtensions
                (old.overrides or (_: _: { }))
                ihaskell.packages."${prev.system}".ihaskell-env.ihaskellOverlay;
          });
        };

        python = import ./nix/python-overlay.nix;

      };
    };
}
