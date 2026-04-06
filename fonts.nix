{ pkgs, config, ... }:

let
  localPackages = pkgs.callPackage ./packages { };
  fonts = localPackages.fonts;
in
{
  fonts.fontconfig.enable = true;
  home.packages = with fonts; [
    pkgs.fira-code
    pkgs.rictydiminished-with-firacode
    cica
    hackgen-nerd
    udev-gothic
    udev-gothic-nf
  ];
}
