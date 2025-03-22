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

## WSL

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.aiotter-system.url = "github:aiotter/systems/nixos";
  inputs.aiotter-system.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {self, nixpkgs, aiotter-system}: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        aiotter-system.nixosModules.wsl
        ./configuration.nix  # add local config
      ];
    };
  };
}
```
