# Rust Nix Flake Quickstart

## Use as a Nix flake template

Full Rust dev shell + CI:

``` sh
nix flake init -t github:data-cartel/rust.nix
```

CI only — drops just `.github/workflows/ci.yaml` into a project that
already has a flake-based dev shell:

``` sh
nix flake init -t github:data-cartel/rust.nix#ci
```

## Use as a flake input

Consume the dev shell directly from another flake without copying any
files. The repo exposes `lib.${system}.{mkDevShell,devenvModule,hooks,toolchain}`.

``` nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-nix.url = "github:data-cartel/rust.nix";
  };

  outputs =
    { nixpkgs, flake-utils, rust-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      # Reuse the default shell as-is:
      devShells.default = rust-nix.devShells.${system}.default;

      # Or compose with extra devenv modules:
      devShells.custom = rust-nix.lib.${system}.mkDevShell {
        extraModules = [
          ({ pkgs, ... }: { packages = [ pkgs.jq ]; })
        ];
      };
    });
}
```

## Prerequisites

Install Nix

``` sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Install Direnv

``` sh
nix -v flake install nixpkgs#direnv
```

Hook Direnv to your shell, e.g. 

``` sh
# For bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc

# For zsh
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

Enable direnv for the local copy of the repo

``` sh
direnv allow
```

Get Rusty!
