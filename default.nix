{ lib, config, pkgs, ... }:

{
  imports = [
    ./bash
    ./fonts.nix
    ./git.nix
    ./mackup
    ./tmux

    ./modules/yubikey-agent
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
    pkgs.gh
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

    # Programming
    pkgs.deno
    # pkgs.nodejs-12_x
    pkgs.rustup
    # pkgs.zig
    pkgs.zigpkgs.default
    pkgs.zls
    pkgs.rnix-lsp

    # GUI
    # pkgs.alacritty
    # pkgs.viewnior  # picture viewer

    # Japanese man page
    pkgs.jaman
  ];

  home.sessionPath = [
    (toString ./bin)
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "UDEV Gothic 35NFLG";
      package = (import ./packages/fonts { inherit pkgs; }).udev-gothic-nf;
      size = 17;
    };
    keybindings = {
      "shift+tab" = "send_text all [9;2u";
      "ctrl+tab" = "send_text all [9;5u";
      "ctrl+shift+tab" = "send_text all [9;6u";
    };
    # theme = "Dot Gov";
    # theme = "Espresso Libre";
    # theme = "Flat";
    # theme = "Galaxy";
    # theme = "Liquid Carbon";
    # theme = "Misterioso";
    # theme = "Monokai Soda";
    # theme = "Obsidian";
    theme = "Oceanic Material";
    # theme = "Royal";
    # theme = "Sakura Night";
    # theme = "Seti";
    # theme = "Spacedust";
    # theme = "Toy Chest";
    # theme = "Ubuntu";
    # theme = "Wez";
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ "yellow" "bold" ];
          inactiveBorderColor = [ "white" ];
          optionsTextColor = [ "blue" ];
        };
        commitLength.show = true;
        showFileTree = true;
        showListFooter = false;
        showRandomTip = false;
      };
      git.paging = {
        colorArg = "always";
        pager = "delta --paging=never --features=traditional --minus-style='\"#606060\" \"#001930\"'";
      };
      reporting = "off";
      disableStartupPopups = true;
      startuppopupversion = 1;
      confirmOnQuit = true;
    };
  };

  programs.ssh = {
    enable = true;
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


    # cachix-watch-store = {
    #   enable = true;
    #   config = {
    #     ProgramArguments = [
    #       (pkgs.cachix + /bin/cachix)
    #       "watch-store"
    #       "aiotter"
    #     ];
    #     RunAtLoad = true;
    #     KeepAlive = true;
    #     StandardOutPath = "${config.home.homeDirectory}/Library/Logs/cachix-watch-store.log";
    #     StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/cachix-watch-store.log";
    #   };
    # };
  };
  services.yubikey-agent.enable = true;
}
