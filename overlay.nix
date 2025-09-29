final: prev:

let
  inherit (final) lib;
in

{
  git-filter-repo = prev.git-filter-repo.overrideAttrs {
    src = final.fetchFromGitHub {
      owner = "newren";
      repo = "git-filter-repo";
      rev = "c1d8461ee34c6d3f987e0f19191f2105cb2a33c8";
      hash = "sha256-s+TTTVoOsADBkmSvdhUELGB5Kv+Arx4KP5EM6p+afHg=";
    };
  };

  p11-kit = prev.p11-kit.overrideAttrs {
    # https://github.com/NixOS/nixpkgs/issues/72838
    doCheck = !final.stdenv.isDarwin;
  };

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
