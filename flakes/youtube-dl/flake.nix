{
  description = "youtube-dl";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    youtube-dl = {
      url = "github:ytdl-org/youtube-dl/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, youtube-dl }:
    {
      overlays.default = final: prev: {
        youtube-dl = self.packages.${prev.system}.default;
      };
    } // utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          buildPythonPackage = pkgs.python310.pkgs.buildPythonPackage;
        in
        rec {
          packages.default = buildPythonPackage rec {
            pname = "youtube-dl";
            version = with youtube-dl; "unstable-${builtins.substring 0 4 lastModifiedDate}-${builtins.substring 4 2 lastModifiedDate}-${builtins.substring 6 2 lastModifiedDate}";
            src = youtube-dl;

            nativeBuildInputs = with pkgs; [ installShellFiles makeWrapper ];
            buildInputs = with pkgs; [ zip atomicparsley ffmpeg rtmpdump ];

            patches = [
              (builtins.toFile "version.patch" ''
                --- a/youtube_dl/version.py
                +++ b/youtube_dl/version.py
                @@ -1,3 +1,3 @@
                 from __future__ import unicode_literals

                -__version__ = '2021.12.17'
                +__version__ = '${version} (${builtins.substring 0 7 youtube-dl.rev})'
              '')
            ];

            setupPyBuildFlags = [ "build_lazy_extractors" ];

            postInstall = ''
              python devscripts/bash-completion.py
              python devscripts/fish-completion.py
              python devscripts/zsh-completion.py
              installShellCompletion --bash youtube-dl.bash-completion
              installShellCompletion youtube-dl.{fish,zsh}
            '';

            doCheck = false;
          };
        });
}
