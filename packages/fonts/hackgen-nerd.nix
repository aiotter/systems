{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "HackGenNF";
  version = "2.7.1";

  src = fetchurl {
      url = "https://github.com/yuru7/HackGen/releases/download/v${version}/HackGen_NF_v${version}.zip";
      hash = "sha256-PBlJaCVn+LTUmEwwsUOfBR8gYqMTjdvyJiwS0If2DZI=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    install -m644 --target $out/share/fonts/truetype/HackGenNF -D HackGen*.ttf
  '';

  meta = {
    description = "Hack と源柔ゴシックを合成したプログラミングフォント 白源 (はくげん／HackGen)";
    homepage = "https://github.com/yuru7/HackGen";
  };
}
