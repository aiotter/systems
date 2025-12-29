{
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
  });
in

{
  environment.systemPackages = [ nix-cli ];
}
