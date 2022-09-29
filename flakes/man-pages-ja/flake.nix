{
  description = "man-pages-ja";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    man-pages-ja = {
      url = "https://linuxjm.osdn.jp/man-pages-ja-20220815.tar.gz";
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
            nativeBuildInputs = with pkgs; [ perl ];
            buildInputs = with pkgs; [ makeWrapper groff ];

            patchPhase = ''
              cp script/configure.perl{,.orig}
              export LANG=ja_JP.UTF-8
              cat script/configure.perl.orig | \
              sed \
                -e '/until/ i $ans = "y";' \
                -e "s#/usr/share/man#$out/share/man#" \
                -e 's/install -o $OWNER -g $GROUP/install/' \
                >script/configure.perl
            '';

            configurePhase = ''
              set +o pipefail
              yes "" | make config
            '';

            postInstall = ''
              # The manpath executable looks up manpages from PATH. And this package won't
              # appear in PATH unless it has a /bin folder
              mkdir -p $out/bin

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
