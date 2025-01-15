{
  description = "aiotter's system settings for macOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, darwin, mac-app-util, ... }:
    let
      darwinSystems = with flake-utils.lib.system; [ x86_64-darwin aarch64-darwin ];
    in
    flake-utils.lib.eachSystem darwinSystems (system: rec {
      darwinConfigurations.default = darwin.lib.darwinSystem
        {
          inherit system;
          modules = [ ./. mac-app-util.darwinModules.default ];
          specialArgs = { flakeInputs = inputs; };
        };

      packages.darwin-system = darwinConfigurations.default.system;
      packages.switch = import ./utils/darwin-switch.nix {
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
    });
}
