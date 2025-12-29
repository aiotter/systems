{
  pkgs,
  lib,
  flakeInputs,
  system,
  ...
}:

let
  patchNixCmd =
    dep:
    if lib.hasSuffix "nix-cmd" dep.pname then
      dep.overrideAttrs (
        prev:
        assert !(prev ? patches);
        {
          patches = [ ./nix-repl-prebind-pkgs.patch ];
          patchFlags = [ "-p1" "-d" "../.." ];
        }
      )
    else
      dep;

  patchDeps = deps: builtins.map patchNixCmd deps;

  nix-cli = flakeInputs.nix-src.packages.${system}.nix-cli.overrideAttrs (prev: {
    buildInputs = patchDeps (prev.buildInputs or [ ]);
    nativeBuildInputs = patchDeps (prev.nativeBuildInputs or [ ]);
    propagatedBuildInputs = patchDeps (prev.propagatedBuildInputs or [ ]);

    patches = (prev.patches or [ ]) ++ [
      (pkgs.fetchpatch {
        url = "https://github.com/DeterminateSystems/nix-src/pull/180.patch";
        hash = "sha256-7G9nX8YT+B9nZXEBICwkAyj2vmSHNqC2C2+dlOpQuIg=";
        relative = "src/nix";
        revert = true;
      })
    ];
  });
in

{
  environment.systemPackages = [ nix-cli ];
}
