{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-nix.url = "github:dataclique/rust.nix";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default = rust-nix.devShells.${system}.default;
    });

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };
}
