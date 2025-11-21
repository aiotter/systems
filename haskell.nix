{ pkgs, lib, ... }:

let
  toYAML = lib.generators.toYAML { };
in

{
  home.packages = [ pkgs.stack ];

  home.file = {
    ".stack/config.yaml".text = toYAML {
      nix = {
        enable = true;
      };
    };

    ".stack/global-project/stack.yaml".text = toYAML {
      snapshot = "lts-24.20";
      packages = [ ];
    };
  };
}
