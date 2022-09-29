{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "HackGenNerd";
  version = "2.3.5";

  src = fetchurl {
      url = "https://github.com/yuru7/HackGen/releases/download/v${version}/HackGenNerd_v${version}.zip";
      sha256 = "55370c08d4d528b57a52024efee835dfe337169c7e5f20089cf4e596aa9a3525";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    install -m644 --target $out/share/fonts/truetype/HackGenNerd -D HackGen*.ttf
  '';

  meta = {
    description = "Hack と源柔ゴシックを合成したプログラミングフォント 白源 (はくげん／HackGen)";
    homepage = "https://github.com/yuru7/HackGen";
  };
}
