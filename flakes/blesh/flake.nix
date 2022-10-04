{
  description = "ble.sh";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ble-sh = {
      type = "git";
      url = "https://github.com/akinomyoga/ble.sh.git";
      ref = "refs/heads/master";
      submodules = true;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ble-sh }: {
    overlays.default = final: prev: {
      blesh = self.packages.${prev.system}.default;
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    rec {
      packages.default = pkgs.stdenv.mkDerivation
        {
          name = "ble.sh";
          src = ble-sh;
          patchPhase = ''
            sed -i"" "/git submodule update/d" GNUmakefile
          '';
          installFlags = [ "PREFIX=$(out)" ];
          checkInputs = with pkgs; [ bashInteractive glibcLocales ];
          preCheck = "export LC_ALL=en_US.UTF-8";
          postInstall = ''
            mkdir -p "$out/bin"
            cat <<EOF >"$out/bin/blesh-share"
            #!${pkgs.runtimeShell}
            # Run this script to find the ble.sh shared folder
            # where all the shell scripts are living.
            echo "$out/share/ble.sh"
            EOF
            chmod +x "$out/bin/blesh-share"

            mkdir -p "$out/share/lib"
            cat <<EOF >"$out/share/lib/_package.sh"
            _ble_base_package_type=nix
            function ble/base/package:nix/update {
              echo "Ble.sh is installed by Nix. You can update it there." >&2
              return 1
            }
            EOF
          '';
        };

      apps.default =
        let
          fileExists = fileName: (builtins.readDir ./.) ? fileName;
          bashrc = pkgs.writeText "bashrc" ''
            source "${packages.default}/share/ble.sh" --noattach ${ if fileExists "blerc" then "--rcfile ${./blerc}" else "" }
            ${ if fileExists "bashrc" then (builtins.readFile ./bashrc) else "" }
            [[ ''${BLE_VERSION-} ]] && ble-attach
          '';
        in
        flake-utils.lib.mkApp {
          drv = pkgs.writeShellApplication {
            name = "blesh-enabled-bash";
            text = ''
              exec ${pkgs.bashInteractive}/bin/bash --rcfile ${bashrc} "$@"
            '';
          };
        };
    });
}
