{ lib, flakeInputs, ... }:

{
  nix = {
    registry = {
      nixpkgs.flake = flakeInputs.nixpkgs-unstable;
      templates.to = {
        type = "github";
        repo = "flakes";
        owner = "aiotter";
        ref = "templates";
      };
    };
  };
}
