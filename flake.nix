{
  description = "declarative and reproducible Jupyter environments - powered by Nix";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/release-21.11;
    flake-utils.url = github:numtide/flake-utils;
    flake-compat.url = github:teto/flake-compat/support-packages;
    flake-compat.flake = false;
    ihaskell.url = github:gibiansky/IHaskell;
  };

  outputs =
    { self
    , nixpkgs
    , ihaskell
    , flake-utils
    , ...
    }:
    (flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ]
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = nixpkgs.lib.attrValues self.overlays;
        };
        defaultJupyterLab = pkgs.jupyterWith.jupyterlabWith {
          kernels = [ (pkgs.jupyterWith.kernels.dyalogKernel { }) ];
        };
      in
      {
        packages.default = defaultJupyterLab;
        devShells.default = defaultJupyterLab.env;
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
