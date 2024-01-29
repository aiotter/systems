{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.wsl.url = "github:nix-community/NixOS-WSL";
  inputs.wsl.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, wsl }: {
    nixosModules = {
      wsl = _: {
        imports = [
          wsl.nixosModules.wsl
          hosts/wsl.nix
          ./common.nix
        ];
      };
    };
  };
}
