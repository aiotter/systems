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
    youtube-dl = {
      url = "github:aiotter/flakes/youtube-dl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pivy = {
      url = "github:aiotter/flakes/pivy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    usbutils = {
      url = "github:aiotter/flakes/usbutils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, blesh-module, ... }@inputs:
    let
      overlays = with inputs; map (input: input.overlays.default)
        [ youtube-dl zig man-pages-ja blesh pivy usbutils ];
    in
    flake-utils.lib.eachDefaultSystem (system: rec {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration rec {
        pkgs = import nixpkgs.outPath {
          inherit system;
          config = { allowUnfree = true; };
        };
        modules = [
          rec {
            home.username = "aiotter";
            nixpkgs.overlays = overlays ++ [
              # https://github.com/kovidgoyal/kitty/issues/5232
              (self: super: {
                kitty = (import
                  (pkgs.fetchFromGitHub {
                    owner = "nixos";
                    repo = "nixpkgs";
                    rev = "3bb443d5d9029e5bf8ade3d367a9d4ba9065162a";
                    hash = "sha256-mdX8Ma70HeGntbZa/zHSjILVurWJ3jwPt7OmQF7vAqQ=";
                  })
                  { inherit system; }).kitty;
              })
            ];
          }
          ./default.nix
          blesh-module.outPath
          # https://github.com/nix-community/home-manager/pull/3210
          ./replace-profile.nix
        ];
      };

      packages.home-manager = home-manager.packages.${system}.default;

      apps.switch = {
        type = "app";
        program = "${homeConfigurations.default.activationPackage}/activate";
      };
    });
}
