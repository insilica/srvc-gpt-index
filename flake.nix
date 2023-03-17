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
        overrides = defaultPoetryOverrides.extend (self: super: {
          gpt-index = super.gpt-index.overridePythonAttrs (old: {
            buildInputs = (old.buildInputs or [ ])
              ++ [ python3Packages.setuptools ];
          });
          llama-index = super.llama-index.overridePythonAttrs (old: {
            propagatedBuildInputs = (old.propagatedBuildInputs or [ ])
              ++ [ python3Packages.setuptools ];
          });
        });
        queryPackage = mkPoetryApplication {
          inherit overrides;
          preferWheels = true;
          projectDir = ./query;
        };
        query = stdenv.mkDerivation {
          name = "srvc-query-gpt-index";
          src = ./query;
          buildInputs = [ queryPackage.dependencyEnv ];
          installPhase = ''
            mkdir -p $out
            cp -r bin $out
          '';
        };
        srvc-docs-index = stdenv.mkDerivation {
          name = "srvc-docs-index";
          src = ./data;
          installPhase = ''
            mkdir $out
            mv srvc.json $out
          '';
        };
        query-srvc-docs = stdenv.mkDerivation {
          name = "query-srvc-docs";
          src = ./data;
          installPhase = ''
            mkdir -p $out/bin
            echo "#!/usr/bin/env bash" > query-srvc-docs
            echo "${query}/bin/srvc-query-gpt-index \"${srvc-docs-index}/srvc.json\" \"\$@\"" >> query-srvc-docs
            chmod +x query-srvc-docs
            mv query-srvc-docs $out/bin
          '';
        };
        trainPackage = mkPoetryApplication {
          inherit overrides;
          preferWheels = true;
          projectDir = ./train;
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
        packages = {
          inherit query query-srvc-docs srvc-docs-index
            train;
        };
        devShells.default = mkShell {
          inherit DOCS_HTML_PATH;
          buildInputs =
            [ trainPackage.dependencyEnv poetry2nix.packages.${system}.poetry ];
        };
      });
}
