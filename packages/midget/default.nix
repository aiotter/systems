{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "Midget";
  version = "0.6";
  src = fetchzip {
    url = "https://github.com/arthur-fontaine/midget/releases/download/v${version}/midget.zip";
    hash = "sha256-aNuUo930JLTz3GUMPjlNEWuvNWiKWywahCPekBU61Qg=";
    stripRoot = false;
  };
  dontBuild = true;
  installPhase = ''
    mkdir -p "$out/Applications"
    mv ./Midget.app "$out/Applications"
  '';
}
