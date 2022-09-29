aiotter's system & user configurations
=====

# Home configurations
System-irrelevant home configuration files including `.bashrc` goes here.

```bash
# Activation
$ nix run github:aiotter/systems#home.switch --impure

# Run CLI
$ nix run github:aiotter/systems#home.home-manager packages
```

# Darwin system
Darwin system configuration.

```bash
# Actication
$ nix run github:aiotter/systems#darwin.switch

# Run CLI
$ nix run github:aiotter/systems#darwin.help
$ nix run github:aiotter/systems#darwin.option launchd.agents
$ nix run github:aiotter/systems#darwin.rebuild changelog
```
