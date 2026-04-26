{
  inputs.aiotter-systems.url = "github:aiotter/systems/master";

  outputs = { self, aiotter-systems }: {
    inherit (aiotter-systems) lib;

    nixosModules =
      {
        minimal.imports = [ aiotter-systems.nixosModules.default ./common.nix ];
        raspi.imports = [ self.nixosModules.minimal hosts/raspi.nix ];
        wsl.imports = [ self.nixosModules.minimal hosts/wsl.nix ];
      };
  };
}
