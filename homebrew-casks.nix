# https://github.com/BatteredBunny/brew-nix

{ lib, pkgs, ... }:

with pkgs.brewCasks;

{
  home.packages = lib.optionals pkgs.stdenv.isDarwin [
    keycastr
  ];
}
