{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.git-hooks.follows = "git-hooks";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      git-hooks,
      fenix,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix.overlays.default ];
        };
        toolchain = fenix.packages.${system}.default;

        lib = import ./nix/lib.nix { inherit pkgs toolchain inputs; };
      in
      {
        inherit lib;

        devShells.default = lib.mkDevShell { };

        packages.devenv-up = self.devShells.${system}.default.config.procfileScript;

        checks = {
          pre-commit = git-hooks.lib.${system}.run {
            src = ./.;
            inherit (lib) hooks;
          };

          # Enforce that the workflow shipped by `templates.ci` is
          # byte-for-byte the workflow that runs on this repo.
          ci-template-mirror = pkgs.runCommandLocal "ci-template-mirror" { } ''
            if ! diff -u \
              ${./.github/workflows/ci.yaml} \
              ${./templates/ci/.github/workflows/ci.yaml}
            then
              echo
              echo "templates/ci/.github/workflows/ci.yaml has drifted" \
                   "from .github/workflows/ci.yaml." >&2
              echo "Update both files to match." >&2
              exit 1
            fi
            touch $out
          '';
        };
      }
    )
    // {
      templates = {
        default = self.templates.rust;

        rust = {
          path = ./.;
          description = "Rust dev shell (devenv + fenix + pre-commit) with CI";
          welcomeText = ''
            # Rust + Nix template

            Next steps:
              1. `direnv allow` (or `nix develop --impure`) to enter the dev shell.
              2. `cargo run` to verify the toolchain.
              3. Edit `Cargo.toml` to set your crate name.

            Optional cleanup: this flake inherits a `templates` output
            that re-exposes the project as a sub-template. If you don't
            plan to re-expose templates from your project, you can
            delete the `templates` block from `flake.nix`. It's
            otherwise harmless.
          '';
        };

        ci = {
          path = ./templates/ci;
          description = "GitHub Actions CI for a Nix-flake Rust project";
          welcomeText = ''
            # CI-only template

            Drops `.github/workflows/ci.yaml` into your project. Assumes
            your flake exposes a `devShells.default` that provides
            `cargo` and `clippy`.
          '';
        };
      };
    };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };
}
