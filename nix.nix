{ lib, flakeInputs, ... }:

{
  nix = {
    registry = {
      nixpkgs.flake = flakeInputs.nixpkgs;
      templates.to = {
        type = "github";
        repo = "flakes";
        owner = "aiotter";
        ref = "templates";
      };
    };
  };
}
