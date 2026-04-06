{ callPackage }:

{
  cica = callPackage ./cica.nix { };
  hackgen-nerd = callPackage ./hackgen-nerd.nix { };
  udev-gothic = callPackage ./udev-gothic.nix { };
  udev-gothic-nf = callPackage ./udev-gothic-nf.nix { };
}
