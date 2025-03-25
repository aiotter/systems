{ lib, config, pkgs, ... }:

{
  imports = [
    ./zsh
    ./fonts.nix
    ./git.nix
    ./mackup

    ./modules/pivy-agent
    ./modules/lazydocker
  ];

  home.stateVersion = "22.05";
  home.username = lib.mkOptionDefault (
    assert pkgs.lib.asserts.assertMsg (builtins ? "currentSystem") "Because home.username is not defined, this derivation must be run in impure mode to get it from $HOME.";
    builtins.getEnv "USER"
  );
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${config.home.username}"
    else "/home/${config.home.username}";

  # nix.registry =
  #   let
  #     flakeDir = "${config.home.homeDirectory}/flakes";
  #     flakeDirExists = config.home.homeDirectory != "" && (builtins.readDir (config.home.homeDirectory)).flakes or "" == "directory";
  #     flakeDirNames = builtins.attrNames (lib.attrsets.filterAttrs (_: fileType: fileType == "directory") (builtins.readDir flakeDir));
  #     flakeList = map
  #       (dirName: {
  #         name = dirName;
  #         value = {
  #           exact = false;
  #           to = { type = "path"; path = "${flakeDir}/${dirName}"; };
  #         };
  #       })
  #       flakeDirNames;
  #     flakes = lib.attrsets.optionalAttrs flakeDirExists (builtins.listToAttrs flakeList);
  #   in
  #   # Add exact=false to all the nix.registry.<name> defined here
  #   flakes // builtins.mapAttrs (_: val: val // { exact = false; }) {
  #     zig.to = { type = "github"; owner = "aiotter"; repo = "zig-on-nix"; };
  #     local.to = { type = "path"; path = config.home.homeDirectory + "/repo/github.com/NixOS/nixpkgs"; };
  #     repo.to = { type = "path"; path = config.home.homeDirectory + "/repo/github.com"; };
  #   };

  home.packages = [
    pkgs.git
    pkgs.bat
    pkgs.dogdns
    pkgs.jq
    pkgs.tree
    pkgs.zsh
    pkgs.delta
    pkgs.universal-ctags
    pkgs.tmux
    pkgs.ffmpeg
    pkgs.wget
    pkgs.aria2 # download manager
    pkgs.unp # unpack (almost) everything
    pkgs.unrar
    pkgs.xclip
    pkgs.httpie
    pkgs.youtube-dl
    pkgs.ghq
    # pkgs.lazygit
    pkgs.jiq # interactive jq
    # pkgs.bitwarden-cli  # trouble building
    pkgs.coreutils-prefixed
    pkgs.gnused
    pkgs.gnutar
    pkgs.gnugrep
    pkgs.gawk
    pkgs.less
    pkgs.starship
    pkgs.fzf
    pkgs.usbutils

    # Programming
    pkgs.cmake
    pkgs.pkg-config
    pkgs.deno
    # pkgs.nodejs-12_x
    # pkgs.rustc
    # pkgs.cargo
    # pkgs.zig
    pkgs.zigpkgs.default
    pkgs.zls
    pkgs.rnix-lsp
    pkgs.go
    pkgs.python-build

    # GUI
    # pkgs.alacritty
    # pkgs.viewnior  # picture viewer

    # Japanese man page
    # pkgs.jaman
  ];

  home.sessionPath = [
    (toString ./bin)
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.bash.bashrcExtra = ''
    _direnv_hook() {
      local previous_exit_status=$?;
      trap -- "" SIGINT;
      eval "$("${pkgs.direnv}/bin/direnv" export bash)";
      trap - SIGINT;
      return $previous_exit_status;
    };
    precmd_functions+=(_direnv_hook)
  '';

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ "yellow" "bold" ];
          inactiveBorderColor = [ "white" ];
          unstagedChangesColor = [ "default" ];
        };
        commitLength.show = true;
        showFileTree = true;
        showListFooter = false;
        showRandomTip = false;
        timeFormat = "2002/01/06";
        shortTimeFormat = "15:04";
        nerdFontsVersion = "3";
      };
      git = {
        autoStageResolvedConflicts = false;
        autoFetch = false;
        commit.autoWrapCommitMessage = false;
        paging = {
          colorArg = "always";
          pager = "delta --paging=never --features=traditional --minus-style='\"#606060\" \"#001930\"'";
        };
        branchLogCmd = "git log --graph --color=always --decorate --date=relative --pretty=full {{branchName}} --";
        truncateCopiedCommitHashesTo = 40;
      };
      os = {
        copyToClipboardCmd = ''printf "\033]52;c;$(printf {{text}} | base64)\a" > /dev/tty'';
      };
      reporting = "off";
      disableStartupPopups = true;
      startuppopupversion = 1;
      # confirmOnQuit = true;

      # keybinding = {
      #   universal.copyToClipboard = "c";
      #   files.commitChanges = "c";
      # };
    };
  };

  programs.lazydocker = {
    enable = true;
    settings = {
      gui = {
        inherit (config.programs.lazygit.settings.gui) theme;
      };
    };
  };

  programs.ssh = {
    enable = true;
    includes = [ "config.local" ];
    compression = true;
    controlMaster = "auto";
    controlPersist = "10m";
    extraOptionOverrides = {
      # PKCS11Provider = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      ForwardAgent = "yes";
    };
    matchBlocks = {
      "aws" = {
        hostname = "3.143.178.205";
        user = "ec2-user";
        port = 22;
        addressFamily = "inet";
      };
    };
  };

  services.pivy-agent = {
    enable = true;
    # guid = "26C3F8E165B498BCFCFE75B53683401E";  # Yubikey NEO
    guid = "E3ADCCBA7F8C7A0F2BFC6410E8566F95"; # Yubikey 5C NFC
  };
}
