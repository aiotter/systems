{
  inputs.aiotter-system.url = "github:aiotter/systems/master";

  outputs = { self, aiotter-system }: {
    nixosModules =
      let
        common-modules = [ aiotter-system.nixosModules.default ./common.nix ];
      in
      {
        raspi.imports = common-modules ++ [ hosts/raspi.nix ];
        wsl.imports = common-modules ++ [ hosts/wsl.nix ];
      };
  };
}
