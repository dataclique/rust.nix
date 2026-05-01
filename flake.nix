{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.git-hooks.follows = "git-hooks";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, flake-utils, devenv, git-hooks, fenix, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix.overlays.default ];
        };
        toolchain = fenix.packages.${system}.default;

        hooks = {
          actionlint.enable = true;
          taplo.enable = true;
          nixfmt-classic.enable = true;
          rustfmt = {
            enable = true;
            packageOverrides = { inherit (toolchain) cargo rustfmt; };
          };
        };

      in {
        devShells = {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [{
              # https://devenv.sh/reference/options/
              packages = with pkgs;
                [ cargo-watch ] ++ lib.optionals stdenv.isDarwin
                (with darwin.apple_sdk; [
                  libiconv
                  frameworks.Security
                  frameworks.CoreFoundation
                  frameworks.SystemConfiguration
                ]);

              env.LOG_LEVEL = "DEBUG";

              languages.rust = {
                enable = true;
                inherit toolchain;
              };

              difftastic.enable = true;
              git-hooks = { inherit hooks; };
            }];
          };
        };

        packages = {
          devenv-up = self.devShells.${system}.default.config.procfileScript;
        };

        checks = {
          pre-commit = git-hooks.lib.${system}.run {
            src = ./.;
            inherit hooks;
          };
        };
      }) // {
        templates = {
          default = self.templates.rust;

          rust = {
            path = ./.;
            description =
              "Rust dev shell (devenv + fenix + pre-commit) with CI";
            welcomeText = ''
              # Rust + Nix template

              Next steps:
                1. `direnv allow` (or `nix develop --impure`) to enter the dev shell.
                2. `cargo run` to verify the toolchain.
                3. Edit `Cargo.toml` to set your crate name.

              Optional cleanup: this template inherits a `templates/`
              subdirectory and a `templates` output in `flake.nix`, used so
              the upstream repo can hand out sub-templates. If you don't
              plan to re-expose templates from your project, you can delete
              both. They are otherwise harmless.
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
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };
}
