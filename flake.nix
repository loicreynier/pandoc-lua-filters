{
  description = "Pandoc Lua filters";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    pre-commit-hooks,
  }: let
    supportedSystems = ["x86_64-linux"];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in rec {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;

          hooks = with pkgs; {
            alejandra.enable = true;
            commitizen.enable = true;
            editorconfig-checker.enable = true;
            prettier.enable = true;
            statix.enable = true;
            stylua.enable = true;
            typos.enable = true;
          };
        };
      };

      packages.default = pkgs.callPackage ./default.nix {};

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          pandoc
          texlive.combined.scheme-basic
        ];
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    });
}
