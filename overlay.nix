final: prev:

let
  inherit (final) lib;
in

{
  devbox =
    let
      flake = builtins.getFlake "github:jetify-com/devbox/${rev}";
      rev = "b589a11e5bef7fd20ebafe4f87d967ed0d5e7c89"; # v0.17.0
    in
    flake.packages.${prev.hostPlatform.system}.default;

  git-filter-repo = prev.git-filter-repo.overrideAttrs {
    src = final.fetchFromGitHub {
      owner = "newren";
      repo = "git-filter-repo";
      rev = "c1d8461ee34c6d3f987e0f19191f2105cb2a33c8";
      hash = "sha256-s+TTTVoOsADBkmSvdhUELGB5Kv+Arx4KP5EM6p+afHg=";
    };
  };

  k9s =
    let
      k9s = prev.k9s.overrideAttrs (old: {
        patches = old.patches or [ ] ++ [
          (final.fetchpatch {
            name = "override-keybinds.patch";
            url = "https://github.com/derailed/k9s/compare/master...aiotter:k9s:master.patch";
            hash = "sha256-1CSli1lZdfg3IkDUBZYwYyDoxa6Yk9W0ulM90U++RXY=";
          })
        ];
        postInstall = [ ]; # Avoid sandbox bug
      });
    in
    final.writeShellScriptBin "k9s" "K9S_FEATURE_GATE_NODE_SHELL=true ${k9s}/bin/k9s \"$@\"";

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
    buildInputs = old.buildInputs ++ [ final.apple-sdk ];
  });
}
