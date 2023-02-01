{
  description = "srvc-gpt-index";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvc = {
      url = "github:insilica/rs-srvc";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, flake-compat, poetry2nix, srvc }:
    flake-utils.lib.eachDefaultSystem (system:
      with import nixpkgs { inherit system; };
      let
        inherit (poetry2nix.legacyPackages.${system})
          defaultPoetryOverrides mkPoetryApplication mkPoetryEnv;
        DOCS_HTML_PATH = srvc.packages.${system}.docs-html;
        trainPackage = mkPoetryApplication {
          inherit DOCS_HTML_PATH;
          preferWheels = true;
          projectDir = ./train;
          overrides = defaultPoetryOverrides.extend (self: super: {
            gpt-index = super.gpt-index.overridePythonAttrs (old: {
              buildInputs = (old.buildInputs or [ ])
                ++ [ python3Packages.setuptools ];
            });
          });
        };
        train = stdenv.mkDerivation {
          name = "srvc-train-gpt-index";
          src = ./train;
          buildInputs = [ trainPackage.dependencyEnv ];
          installPhase = ''
            mkdir -p $out
            cp -r bin $out
          '';
        };
      in {
        packages = { inherit train; };
        devShells.default = mkShell {
          inherit DOCS_HTML_PATH;
          buildInputs =
            [ trainPackage.dependencyEnv poetry2nix.packages.${system}.poetry ];
        };
      });
}
