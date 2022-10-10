{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) callPackage;
in
{
  inherit (pkgs) fira-code ricty rictydiminished-with-firacode;
  cica = callPackage ./cica.nix { };
  hackgen-nerd = callPackage ./hackgen-nerd.nix { };
  udev-gothic = callPackage ./udev-gothic.nix { };
  udev-gothic-nf = callPackage ./udev-gothic-nf.nix { };
}
