# NixOS Configurations

## Common notice

Make sure to add the following to the local config file (`./configuration.nix`).

```nix
# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It's perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
system.stateVersion = "23.11"; # Did you read the comment?
```

## RasPi

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    aiotter-system.url = "github:aiotter/systems/nixos";
  };

  outputs = { self, nixpkgs, nixos-hardware, aiotter-system }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        aiotter-system.nixosModules.raspi
        nixos-hardware.nixosModules.raspberry-pi-4
        ./configuration.nix # local config
      ];
    };
  };
}
```

## WSL

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    wsl.url = "github:nix-community/NixOS-WSL";
    aiotter-system.url = "github:aiotter/systems/nixos";
  }

  outputs = { self, nixpkgs, aiotter-system }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        aiotter-system.nixosModules.wsl
        wsl.nixosModules.wsl
        ./configuration.nix # local config
      ];
    };
  };
}
```
