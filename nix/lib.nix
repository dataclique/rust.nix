{
  pkgs,
  toolchain,
  inputs,
}:
let
  hooks = {
    actionlint.enable = true;
    taplo.enable = true;
    nixfmt.enable = true;

    rustfmt = {
      enable = true;
      packageOverrides = { inherit (toolchain) cargo rustfmt; };
    };
  };

  devenvModule =
    { ... }:
    {
      packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.libiconv ];

      languages.rust = {
        enable = true;
        inherit toolchain;
      };

      difftastic.enable = true;
      git-hooks = { inherit hooks; };
    };

  mkDevShell =
    {
      extraModules ? [ ],
    }:
    inputs.devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [ devenvModule ] ++ extraModules;
    };
in
{
  inherit
    toolchain
    hooks
    devenvModule
    mkDevShell
    ;
}
