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
