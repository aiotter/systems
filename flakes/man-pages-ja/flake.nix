{
  description = "man-pages-ja";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    man-pages-ja = {
      url = "git+https://scm.osdn.net/gitroot/linuxjm/jm.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, man-pages-ja }:
    {
      overlays.default = (final: prev: {
        jaman = self.packages.${prev.system}.default;
      });
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        # Don't use pkgs.man; it has no config related to Japanese output
        packages.default = pkgs.stdenv.mkDerivation
          {
            name = "man-pages-ja";
            src = man-pages-ja;
            # nativeBuildInputs = with pkgs; [ perl ];
            buildInputs = with pkgs; [ makeWrapper groff ];
            dontBuild = true;
            installPhase = ''
              mkdir -p "$out/share/man/man"{1..8}
              cp -n manual/**/release/man1/* "$out/share/man/man1"
              cp -n manual/**/release/man2/* "$out/share/man/man2"
              cp -n manual/**/release/man3/* "$out/share/man/man3"
              cp -n manual/**/release/man4/* "$out/share/man/man4"
              cp -n manual/**/release/man5/* "$out/share/man/man5"
              cp -n manual/**/release/man6/* "$out/share/man/man6"
              cp -n manual/**/release/man7/* "$out/share/man/man7"
              cp -n manual/**/release/man8/* "$out/share/man/man8"

              # For manpath
              mkdir -p "$out/bin"

              mkdir -p $out/etc
              echo "JNROFF ${pkgs.groff}/bin/groff -Dutf8 -Tutf8 -mandoc -mja -E" >$out/etc/man.conf

              makeWrapper /usr/bin/man "$out/bin/jaman" \
                --set MANPATH $out/share/man \
                --set LANG ja_JP.UTF-8 \
                --add-flags "-C$out/etc/man.conf"
            '';

            outputDocdev = "out";

            meta = {
              mainProgram = "jaman";
              priority = 30;
            };
          };
      });
}
