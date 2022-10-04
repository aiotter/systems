{ lib, config, pkgs, ... }:

{
  imports = [
    ./bash
    ./fonts.nix
    ./git.nix
    ./mackup
    ./tmux
  ];

  home.stateVersion = "22.05";
  home.username = builtins.getEnv "USER";
  home.homeDirectory = /. + (builtins.getEnv "HOME");

  # nix.registry =
  #   let
  #     flakeDir = "${builtins.getEnv "HOME"}/flakes";
  #     flakeDirExists = builtins.getEnv "HOME" != "" && (builtins.readDir (builtins.getEnv "HOME")).flakes or "" == "directory";
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
  #     local.to = { type = "path"; path = builtins.getEnv "HOME" + "/repo/github.com/NixOS/nixpkgs"; };
  #     repo.to = { type = "path"; path = builtins.getEnv "HOME" + "/repo/github.com"; };
  #   };

  home.packages = [
    pkgs.neovim
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
    pkgs.zigpkgs.master
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
    package =
      # https://github.com/kovidgoyal/kitty/issues/5232
      (import
        (pkgs.fetchFromGitHub {
          owner = "nixos";
          repo = "nixpkgs";
          rev = "3bb443d5d9029e5bf8ade3d367a9d4ba9065162a";
          hash = "sha256-mdX8Ma70HeGntbZa/zHSjILVurWJ3jwPt7OmQF7vAqQ=";
        })
        { }).kitty;
    font = {
      name = "HackGenNerd Console";
      package = (import ../packages/fonts { inherit pkgs; }).hackgen-nerd;
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
      IdentityAgent = "${builtins.getEnv "HOME"}/.cache/yubikey-agent/agent.sock";
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

  launchd.agents = {
    yubikey-agent = {
      enable = true;
      config = {
        ProgramArguments = [
          (pkgs.yubikey-agent + /bin/yubikey-agent)
          "-l"
          "${builtins.getEnv "HOME"}/.cache/yubikey-agent/agent.sock"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${builtins.getEnv "HOME"}/Library/Logs/yubikey-agent.log";
        StandardErrorPath = "${builtins.getEnv "HOME"}/Library/Logs/yubikey-agent.log";
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
    #     StandardOutPath = "${builtins.getEnv "HOME"}/Library/Logs/cachix-watch-store.log";
    #     StandardErrorPath = "${builtins.getEnv "HOME"}/Library/Logs/cachix-watch-store.log";
    #   };
    # };
  };
}
