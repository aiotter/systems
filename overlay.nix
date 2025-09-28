final: prev:

let
  inherit (final) lib;
in

{

  tig = final.writeShellScriptBin "tig" ''
    ESCDELAY=''${ESCDELAY:-80} ${lib.getExe prev.tig}
  '';

  tio = prev.tio.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "tio";
      repo = "tio";
      rev = "3af4c5591e0183ea9871654ea4d62254ac23226d";
      hash = "sha256-OBf0fbfdXkIcXPUFOLgDXP6bMSg4rAzCkbz40oV3Lyg=";
    };
    buildInputs = old.buildInputs ++ [ final.apple-sdk_12 ];
  });
}
