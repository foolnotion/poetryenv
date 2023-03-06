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
          buildInputs = [ pkgs.poetry ];

        };

        devShells.default = pkgs.mkShell rec {
          myenv = mkPoetryEnv {
            projectDir = self;
            overrides = defaultPoetryOverrides.extend (self: super: {
              cmaes = super.cmaes.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
              });
              optuna = super.optuna.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
              });
              pmlb = super.pmlb.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
              });
              matplotlib = super.matplotlib.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.pybind11 ];
              });
              rfc3986-validator = super.rfc3986-validator.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools super.pytest-runner ];
              });
              jupyter-events = super.jupyter-events.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.hatchling ];
              });
              jupyter-server = super.jupyter-server.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.hatchling ];
              });
              jupyter-server-terminals = super.jupyter-server-terminals.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.hatchling ];
              });
              y-py = super.y-py.overrideAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.pkgs.maturin ];
              });
            });
          };

          pyoperon_ = pyoperon.packages.${system}.default;
          buildInputs = [
            pkgs.poetry
            myenv
            pyoperon_
            (pkgs.vscode-with-extensions.override {
              vscodeExtensions = with pkgs.vscode-extensions; [ ms-python.python ms-toolsai.jupyter ];
            })
          ];

          shellHook = ''
            export PYTHONPATH=$PYTHONPATH:${pyoperon_}
            '';
        };
      });
}
