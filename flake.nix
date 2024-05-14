{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyoperon = {
      #url = "github:heal-research/pyoperon";
      url = "path:/home/bogdb/src/pyoperon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vstat = {
      url = "path:/home/bogdb/src/vstat";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, pyoperon, vstat }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv;

        myEnv = mkPoetryEnv {
          projectDir = self;
          preferWheels = true;
        };

        pythonVersion = "python${pkgs.python3.sourceVersion.major}.${pkgs.python3.sourceVersion.minor}";
        pyoperon_ = pyoperon.packages.${system}.default ;
        vstat_ = vstat.packages.${system}.default;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ myEnv ]; 
          packages = [
            pkgs.poetry
            pyoperon_
          ];
        };

        devShells.poetryOnly = pkgs.mkShell {
          packages = [ pkgs.poetry ];
        };
      });
}
