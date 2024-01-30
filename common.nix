{ config, pkgs, lib, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://aiotter.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "aiotter.cachix.org-1:YaYTZbiaiBIUYsJPwhcgG9yXXWd15xPtGmvq7DEmKnE="
    ];
    auto-optimise-store = true;
  };

  time.timeZone = "Asia/Tokyo";

  environment.systemPackages = with pkgs; [
    curl
    gcc
    gnumake
    vim
    wget
  ];

  services.openssh = {
    enable = true;
    settings = {
      AllowAgentForwarding = true;
      X11Forwarding = lib.mkIf config.services.xserver.enable true;
    };
  };
}
