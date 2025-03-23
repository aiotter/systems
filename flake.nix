{
  inputs.aiotter-systems.url = "github:aiotter/systems/master";

  outputs = { self, aiotter-systems }: {
    inherit (aiotter-systems) lib;

    nixosModules =
      let
        common-modules = [ aiotter-systems.nixosModules.default ./common.nix ];
      in
      {
        raspi.imports = common-modules ++ [ hosts/raspi.nix ];
        wsl.imports = common-modules ++ [ hosts/wsl.nix ];
      };
  };
}
