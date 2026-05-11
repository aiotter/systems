{
  description = "aiotter's user settings";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
    };
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
      inputs.nixpkgs.follows = "home-manager/nixpkgs";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
    # man-pages-ja = {
    #   url = "github:aiotter/man-pages-ja";
    #   inputs.nixpkgs.follows = "home-manager/nixpkgs";
    # };
    youtube-dl = {
      url = "github:aiotter/flakes/youtube-dl";
      inputs.nixpkgs.follows = "home-manager/nixpkgs";
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "home-manager/nixpkgs";
    };
    pivy = {
      url = "github:aiotter/flakes/pivy";
      inputs.nixpkgs.follows = "home-manager/nixpkgs";
    };
    usbutils = {
      url = "github:aiotter/flakes/usbutils";
      inputs.nixpkgs.follows = "home-manager/nixpkgs";
    };
    python-build = {
      url = "github:aiotter/flakes/python-build";
      inputs.nixpkgs.follows = "home-manager/nixpkgs";
    };
    reload = {
      url = "github:aiotter/flakes/reload";
      inputs.nixpkgs.follows = "home-manager/nixpkgs";
    };
    yazi = {
      url = "github:sxyazi/yazi/v26.1.22";
      inputs.nixpkgs.follows = "home-manager/nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs-unstable, flake-utils, home-manager, ... }@inputs:
    let
      overlays = with inputs; [
        brew-nix.overlays.default
        youtube-dl.overlays.default
        zig.overlays.default
        pivy.overlays.default
        usbutils.overlays.default
        python-build.overlays.default
        reload.overlays.default
        yazi.overlays.default
        (import ./overlay.nix)
      ];

      mkPkgs = input: system: import input {
        inherit system overlays;
        config = { allowUnfree = true; };
      };
    in
    flake-utils.lib.eachDefaultSystem (system: rec {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs home-manager.inputs.nixpkgs.outPath system;

        modules = [
          {
            home.username = "aiotter";
            nixpkgs.overlays = overlays;
          }
          ./default.nix
        ];

        extraSpecialArgs = {
          flakeInputs = inputs;
          pkgsUnstable = mkPkgs nixpkgs-unstable system;
        };
      };

      packages = {
        default = self.homeConfigurations.${system}.default.config.home.path;
        home-manager = home-manager.packages.${system}.default;
      }
      // self.homeConfigurations.${system}.default.pkgs.callPackage ./packages { };

      apps.switch = {
        type = "app";
        program = "${homeConfigurations.default.activationPackage}/activate";
      };
    }) // {
      nixConfig = {
        extra-substituters = ["https://aiotter.cachix.org"];
        extra-trusted-public-keys = ["aiotter.cachix.org-1:YaYTZbiaiBIUYsJPwhcgG9yXXWd15xPtGmvq7DEmKnE="];
      };
    };
}
