# https://github.com/BatteredBunny/brew-nix

{ lib, pkgs, ... }:

with pkgs.brewCasks;

{
  home.packages = lib.optionals pkgs.stdenv.isDarwin [
    # A virtual monitor for screen sharing
    deskpad

    # An open-source keystroke visualizer
    keycastr
  ];
}
