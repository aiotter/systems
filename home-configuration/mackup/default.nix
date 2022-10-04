{ pkgs, lib, config, ... }:

{
  home.file = lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
    ".mackup.cfg".source = ./mackup.cfg;
    ".mackup".source = ./settings;
  };
}
