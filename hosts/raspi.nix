{ pkgs, ... }: {
  nix.settings = {
    auto-optimise-store = true;
    min-free = 2 * 1024 * 1024 * 1024;
    max-free = 4 * 1024 * 1024 * 1024;
  };

  zramSwap.enable = true;

  # swapDevices = [
  #   { device = "/swap"; size = 1024; }
  # ];
}
