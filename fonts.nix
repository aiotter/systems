{ pkgs, config, ... }:

let
  fonts = import ./packages/fonts { inherit pkgs; };
in
{
  fonts.fontconfig.enable = true;
  home.packages = with fonts; [
    fira-code
    rictydiminished-with-firacode
    cica
    hackgen-nerd
    udev-gothic
  ];
}
