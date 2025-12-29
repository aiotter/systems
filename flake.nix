{
  description = "aiotter's system settings for macOS";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixpkgs.follows = "determinate/nixpkgs";
    nix-src.follows = "determinate/nix";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      # https://github.com/hraban/mac-app-util/issues/39#issuecomment-3503946041
      inputs.cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    flakeInputs@{ self, nixpkgs, nix-src, darwin, determinate, mac-app-util }:
    let
      inherit (nixpkgs) lib;
      darwinSystems = lib.systems.doubles.darwin;
    in
    {
      packages = lib.genAttrs darwinSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          darwinConfig = darwin.lib.darwinSystem {
            inherit system;
            modules = [
              determinate.darwinModules.default
              mac-app-util.darwinModules.default
              ./.
            ];
            specialArgs = { inherit flakeInputs system; };
          };
        in
        {
          default = darwinConfig.system;

          darwinConfigurations.default = darwinConfig;

          inherit (darwin.packages.${system}) darwin-option darwin-rebuild darwin-version darwin-uninstaller;

          # switch = pkgs.writeShellScriptBin "switch" ''
          #   sudo "${lib.getExe darwin-rebuild}" switch --flake "${self}#default" "$@"
          # '';

          switch = pkgs.writeShellScriptBin "switch" ''
            sudo "${darwinConfig.system}/sw/bin/darwin-rebuild" activate "$@"
          '';
        }
      );
    };
}
