{
  description = "aiotter's user settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blesh = {
      url = "github:aiotter/flakes/blesh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blesh-module = {
      url = "https://raw.githubusercontent.com/aiotter/home-manager/master/modules/programs/blesh.nix";
      flake = false;
    };
    man-pages-ja = {
      url = "github:aiotter/man-pages-ja";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim = {
      url = "github:aiotter/neovim";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    youtube-dl = {
      url = "github:aiotter/flakes/youtube-dl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, blesh-module, ... }@inputs:
    let
      overlays = with inputs; [
        youtube-dl.overlays.default
        # (final: prev: { zig = zig.packages.${system}.master; })
        zig.overlays.default
        man-pages-ja.overlays.default
        blesh.overlays.default
        neovim.overlays.default
      ];
    in
    flake-utils.lib.eachDefaultSystem (system: rec {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./default.nix
          blesh-module.outPath
          { nixpkgs.overlays = overlays; }
          # https://github.com/nix-community/home-manager/pull/3210
          ./replace-profile.nix
        ];
      };

      packages.home-manager = home-manager.packages.${system}.default;

      apps.switch = (
        assert nixpkgs.lib.asserts.assertMsg (builtins ? "currentSystem") "In order to get $USER and $HOME, this derivation must be run in impure mode.";
        {
          type = "app";
          program = "${homeConfigurations.default.activationPackage}/activate";
        }
      );
    });
}
