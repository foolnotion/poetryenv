{
  description = "poetry2nix python environment";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.pyoperon = {
    url = "github:heal-research/pyoperon/cpp20";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, pyoperon }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see for more functions and examples.
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryEnv;
        inherit (poetry2nix.legacyPackages.${system}) defaultPoetryOverrides;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ poetry2nix.overlay ];
        };
      in {
        devShells.poetryOnly = pkgs.mkShell {
          buildInputs = [ poetry2nix.packages.${system}.poetry ];
        };

        devShells.default = pkgs.mkShell rec {
          myenv = mkPoetryEnv {
            projectDir = self;
            preferWheels = true;
          };

          pyoperon_ = pyoperon.packages.${system}.default;
          buildInputs = [
            pkgs.poetry
            myenv
          ];

          shellHook = ''
            export PYTHONPATH=$PYTHONPATH:${pyoperon_}
            '';
        };
      });
}
