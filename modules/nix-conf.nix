{ lib, flakeInputs, ... }:

{
  # Let Determinate Nix handle Nix configuration
  nix.enable = false;

  determinate-nix.customSettings = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://aiotter.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "aiotter.cachix.org-1:YaYTZbiaiBIUYsJPwhcgG9yXXWd15xPtGmvq7DEmKnE="
    ];

    extra-trusted-users = [ "@admin" ];
    experimental-features = "nix-command flakes pipe-operators";
    bash-prompt = ''[nix]\W$ '';
    warn-dirty = false;
  };
}
