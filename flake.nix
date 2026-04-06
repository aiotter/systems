{
  description = "aiotter's user settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
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
    reload = {
      url = "github:aiotter/flakes/reload";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi = {
      url = "github:sxyazi/yazi/v26.1.22";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }@inputs:
    let
      overlays = with inputs; [ (import ./overlay.nix) ] ++ map (input: input.overlays.default)
        [ brew-nix youtube-dl zig pivy usbutils python-build reload yazi ];
    in
    flake-utils.lib.eachDefaultSystem (system: rec {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs.outPath {
          inherit system overlays;
          config = { allowUnfree = true; };
        };
        modules = [
          {
            home.username = "aiotter";
            nixpkgs.overlays = overlays;
          }
          ./default.nix
        ];
        extraSpecialArgs.flakeInputs = inputs;
      };

      packages = {
        default = self.homeConfigurations.${system}.default.config.home.path;
        home-manager = home-manager.packages.${system}.default;
      };

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
