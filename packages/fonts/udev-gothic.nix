{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "UDEV-gothic";
  version = "1.0.1";

  src = fetchurl {
      url = "https://github.com/yuru7/udev-gothic/releases/download/v${version}/UDEVGothic_v${version}.zip";
      hash = "sha256-UR/K/rl97H9GRlPXAmuAuYfCAxHZqCR8A7qUbbncpF4=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    install -m644 --target $out/share/fonts/truetype/UDEVGothic -D UDEVGothic*.ttf
  '';

  meta = {
    description = "UDEV Gothic は、ユニバーサルデザインフォントのBIZ UDゴシックと、開発者向けフォントの JetBrains Mono を合成した、プログラミング向けフォントです。";
    homepage = "https://github.com/yuru7/udev-gothic";
  };
}