{ lib, config, pkgs, ... }:

{
  imports = [
    ./zsh
    ./fonts.nix
    ./git.nix
    ./mackup

    ./modules/pivy-agent
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
    pkgs.go
    pkgs.python-build

    # GUI
    # pkgs.alacritty
    # pkgs.viewnior  # picture viewer
    pkgs.dive # docker container inspector

    # Japanese man page
    # pkgs.jaman
  ];

  home.sessionPath = [
    (toString ./bin)
  ];

  targets.darwin = {
    keybindings = {
      "@^v" = "pasteAsPlainText:"; # cmd-ctrl-v
      "^u" = "deleteToBeginningOfParagraph:"; # ctrl-u

      # https://gist.github.com/yujiod/9823541
      "¥" = [ "insertText:" "\\\\" ];
      "~\\\\" = [ "insertText:" "¥" ];
    };

    currentHostDefaults = {
      "com.apple.controlcenter".BatteryShowPercentage = true;
    };

    defaults = {
      NSGlobalDomain.ApplePressAndHoldEnabled = true;
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.KeyRepeat = 10;
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.Safari".IncludeDevelopMenu = true;
      "com.apple.Safari".ShowOverlayStatusBar = true;
      "com.apple.desktopservices".DSDontWriteNetworkStores = true;
      "com.apple.desktopservices".DSDontWriteUSBStores = true;
      "com.apple.finder".AppleShowAllFiles = true;
      "com.apple.finder".FXRemoveOldTrashItems = true;
      "com.apple.finder".ShowPathBar = true;

      # https://apple.stackexchange.com/a/462849
      NSGlobalDomain.NSInitialToolTipDelay = 800;

      # tweaks
      "com.apple.finder".QuitMenuItem = true;
      "com.apple.finder".PathBarRootAtHome = true;
      "com.apple.finder".QLEnableTextSelection = true;
      "com.apple.finder".QLHidePanelOnDeactivate = true;
      "com.apple.CrashReporter".DialogType = "none";
    };
  };

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

  programs.k9s = {
    enable = true;
    package =
      let
        k9s = pkgs.k9s.overrideAttrs (prev: {
          patches = prev.patches or [ ] ++ [
            (pkgs.fetchpatch {
              name = "override-keybinds.patch";
              url = "https://github.com/aiotter/k9s/commit/8ff090b6131387f29145a3b63597e4321b6db44b.patch";
              hash = "sha256-1CSli1lZdfg3IkDUBZYwYyDoxa6Yk9W0ulM90U++RXY=";
            })
          ];
          postInstall = [ ]; # Avoid sandbox bug
        });
      in
      pkgs.writeShellScriptBin "k9s" "K9S_FEATURE_GATE_NODE_SHELL=true ${k9s}/bin/k9s \"$@\"";
    settings = {
      k9s = {
        liveViewAutoRefresh = true;
        noExitOnCtrlC = true;
        ui = {
          enableMouse = true;
          logoless = true;
          noIcons = true;
        };
        shellPod = {
          image = "alpine/k8s:1.31.3";
          namespace = "default";
          limits = {
            cpu = "100m";
            memory = "100Mi";
          };
        };
      };
    };
    views.views = {
      "v1/events" = {
        sortColumn = "LAST_SEEN:asc";
        columns = [ "LAST SEEN" "TYPE" "REASON" "OBJECT" "MESSAGE" ];
      };
    };
    plugin.plugins = {
      hostname = {
        shortCut = "Shift-H";
        description = "external-dns";
        scopes = [ "all" ];
        command = "sh";
        background = false;
        args = [
          "-c"
          "kubectl --kubeconfig=$KUBECONFIG get service,ingress --all-namespaces --context=$CONTEXT --sort-by=.metadata.namespace --output=custom-columns=SERVICE:.metadata.name,HOSTNAME:'.metadata.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname' | awk '$2!=\"<none>\" {print $0}' | column -t | ${pkgs.less}/bin/less --clear-screen --lesskey-content='\\e\\e quit' --tilde --header=1 --no-search-headers --color=H-_"
        ];
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
