{
  description = "aiotter's user settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # man-pages-ja = {
    #   url = "github:aiotter/man-pages-ja";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
    python-build = {
      url = "github:aiotter/flakes/python-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }@inputs:
    let
      overlays = with inputs; map (input: input.overlays.default)
        [ youtube-dl zig pivy usbutils python-build ];
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
            nixpkgs.overlays = overlays;
            # FIXME: Need bugfix
            # nixpkgs.overlays = overlays ++ [
            #   (self: super: {
            #     kitty = pkgs.kitty.overrideAttrs (prev: rec {
            #       version = "0.26.5";
            #       src = pkgs.fetchFromGitHub {
            #         owner = "kovidgoyal";
            #         repo = "kitty";
            #         rev = "v${version}";
            #         hash = "sha256-UloBlV26HnkvbzP/NynlPI77z09MBEVgtrg5SeTmwB4=";
            #       };
            #     });
            #   })
            # ];
          }
          ./default.nix
        ];
      };

      packages.home-manager = home-manager.packages.${system}.default;

      apps.switch = {
        type = "app";
        program = "${homeConfigurations.default.activationPackage}/activate";
      };
    });
}
