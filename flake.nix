{
  description = "aiotter's user settings";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    };
  };

  outputs = { self, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      inherit (nixpkgs-unstable) lib;
      systems = builtins.attrNames home-manager.packages;

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

      mkHomeConfiguration = system:
        let
          pkgsUnstable = mkPkgs nixpkgs-unstable system;
          localPackages = pkgsUnstable.callPackage ./packages { };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs home-manager.inputs.nixpkgs.outPath system;

          modules = [
            {
              home.username = "aiotter";
              nixpkgs.overlays = overlays;
            }
            ./default.nix
          ];

          extraSpecialArgs = {
            inherit localPackages pkgsUnstable;
            flakeInputs = inputs;
          };
        };
    in {
      homeConfigurations = lib.genAttrs systems mkHomeConfiguration;

      packages = lib.genAttrs systems (system:
        let
          localPackages = (mkPkgs nixpkgs-unstable system).callPackage ./packages { };
        in
        {
          default = self.homeConfigurations.${system}.config.home.path;
          home-manager = home-manager.packages.${system}.default;
        }
        // localPackages);

      apps = lib.genAttrs systems (
        system:
        let
          pkgs = mkPkgs nixpkgs-unstable system;

          mkApp = drv: {
            type = "app";
            program = lib.getExe drv;
          };

          mkNhHomeScript =
            subcommand:
            pkgs.writeShellApplication {
              name = "nh-home-${subcommand}";
              runtimeInputs = with pkgs; [ nh ];
              text = ''
                exec nh home ${subcommand} path:${self} --configuration ${system} "$@"
              '';
            };

          # https://github.com/nix-community/nh/issues/384
          replScript = pkgs.writeShellApplication {
            name = "home-repl";
            runtimeInputs = with pkgs; [ nix ];
            text = ''
              exec nix repl "path:${self}#homeConfigurations.${system}" "$@"
            '';
          };
        in
        {
          build = mkApp (mkNhHomeScript "build");
          switch = mkApp (mkNhHomeScript "switch");
          repl = mkApp replScript;
        }
      );
    } // {
      nixConfig = {
        extra-substituters = ["https://aiotter.cachix.org"];
        extra-trusted-public-keys = ["aiotter.cachix.org-1:YaYTZbiaiBIUYsJPwhcgG9yXXWd15xPtGmvq7DEmKnE="];
      };
    };
}
