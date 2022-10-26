{
  description = "aiotter's system and user settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blesh = {
      url = "github:aiotter/flakes/blesh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blesh-module = {
      url = "https://raw.githubusercontent.com/aiotter/home-manager/9e8d03d4d4d728c8128328f62c04209d7a6e1ae3/modules/programs/blesh.nix";
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

  outputs = { self, nixpkgs, flake-utils, darwin, home-manager, blesh-module, ... }@inputs:
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
    builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate { } [
      (
        # Home manager
        flake-utils.lib.eachDefaultSystem (system: rec {
          homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            modules = [
              ./home-configuration
              blesh-module.outPath
              { nixpkgs.overlays = overlays; }
              # https://github.com/nix-community/home-manager/pull/3210
              ./home-configuration/replace-profile.nix
            ];
          };

          packages.home-manager = home-manager.packages.${system}.default;
          packages.home-switch = (
            assert nixpkgs.lib.asserts.assertMsg (builtins ? "currentSystem") "In order to get $USER and $HOME, this derivation must be built in impure mode.";
            homeConfigurations.default.activationPackage
          );

          apps.home-switch = (
            assert nixpkgs.lib.asserts.assertMsg (builtins ? "currentSystem") "In order to get $USER and $HOME, this derivation must be run in impure mode.";
            {
              type = "app";
              program = "${homeConfigurations.default.activationPackage}/activate";
            }
          );
        })
      )

      (
        # Darwin
        let
          darwinSystems = with flake-utils.lib.system; [ x86_64-darwin aarch64-darwin ];
        in
        flake-utils.lib.eachSystem darwinSystems (system: rec {
          darwinConfigurations.default = darwin.lib.darwinSystem
            {
              inherit system;
              modules = [ ./darwin-configuration ];
            };

          packages.darwin-system = darwinConfigurations.default.system;
          packages.darwin-switch = import ./utils/darwin-switch.nix {
            pkgs = nixpkgs.legacyPackages.${system};
            darwinConfiguration = darwinConfigurations.default;
          };

          apps.darwin-help = {
            type = "app";
            program = "${packages.darwin-system}/sw/bin/darwin-help";
          };
          apps.darwin-option = {
            type = "app";
            program = "${packages.darwin-system}/sw/bin/darwin-option";
          };
          apps.darwin-rebuild = {
            type = "app";
            program = "${packages.darwin-system}/sw/bin/darwin-rebuild";
          };
        })
      )
    ];
}
