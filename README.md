aiotter's user configurations
=====
```bash
# Activation
$ nix run github:aiotter/systems/home#switch

# Run Home Manager CLI
$ nix run github:aiotter/systems/home/home-manager packages
```

## Notion
Determinate Nix on macOS creates `~/.local/state` belonging to root ([issue](https://github.com/DeterminateSystems/nix-installer/issues/1665)).
You may have to `chown` the directory to your local user.
