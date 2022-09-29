{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "cica";
  version = "5.0.3";
  src = fetchurl {
    url = "https://github.com/miiton/Cica/releases/download/v${version}/Cica_v${version}.zip";
    sha256 = "cbd1bcf1f3fd1ddbffe444369c76e42529add8538b25aeb75ab682d398b0506f";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    install -m644 --target $out/share/fonts/truetype/Cica -D Cica-*.ttf
  '';

  meta = {
    description = "プログラミング用日本語等幅フォント Cica(シカ)";
    homepage = "https://github.com/miiton/Cica";
  };
}
