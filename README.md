aiotter's system configurations for macOS
=====

# Requirements
## Nix
Follow instructions [here](https://nixos.org/download.html#nix-install-macos).

## Homebrew
Follow instructions [here](https://brew.sh).
```bash
# Actication
$ nix run github:aiotter/systems/darwin#switch

# Run nix-darwin CLI
$ nix run github:aiotter/systems/darwin#darwin-help
$ nix run github:aiotter/systems/darwin#darwin-option launchd.agents
$ nix run github:aiotter/systems/darwin#darwin-rebuild changelog
```
