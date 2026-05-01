# rust.nix

A Rust + Nix template: devenv-based dev shell, fenix Rust toolchain,
pre-commit hooks (rustfmt, nixfmt, taplo, actionlint), a sample
`clap` + `tracing` binary, and a GitHub Actions CI workflow.

Consumable two ways: as a GitHub template repo (the green "Use this
template" button) or as a Nix flake template (`nix flake init -t`).

## Use as a Nix flake template

Full Rust dev shell + CI:

``` sh
nix flake init -t github:data-cartel/rust.nix
# or, equivalently
nix flake init -t github:data-cartel/rust.nix#rust
```

CI only — drops just `.github/workflows/ci.yaml` into a project that
already has a flake-based dev shell:

``` sh
nix flake init -t github:data-cartel/rust.nix#ci
```

## Quick start (after bootstrap)

Install Nix:

``` sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Install direnv (via Nix):

``` sh
nix profile install nixpkgs#direnv
```

Hook direnv into your shell:

``` sh
# bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && source ~/.bashrc
# zsh
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc && source ~/.zshrc
```

Enable direnv for the project:

``` sh
direnv allow
```

Get Rusty!
