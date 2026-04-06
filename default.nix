{ lib, config, pkgs, ... }:

let
  localPackages = pkgs.callPackage ./packages { };
in

{
  imports = [
    ./nix.nix
    ./zsh
    ./fonts.nix
    ./git.nix
    ./mackup
    ./haskell.nix
    ./ranger.nix
    ./yazi.nix
    ./process-compose.nix

    ./homebrew-casks.nix

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

  xdg.enable = true;

  home.packages = [
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
    pkgs.reload
    pkgs.tio # serial device I/O tool
    pkgs.with-shell
    pkgs.jwt-cli
    pkgs.devbox
    pkgs.dysk

    # Programming
    pkgs.deno
    # pkgs.rustc
    # pkgs.cargo
    # pkgs.zig
    pkgs.zigpkgs.default
    pkgs.zls
    pkgs.go
    pkgs.python-build

    # GUI
    # pkgs.viewnior  # picture viewer
    pkgs.dive # docker container inspector

    # local packages
    localPackages.qr
  ];

  home.sessionPath = [
    (toString ./bin)
  ];

  targets.darwin = {
    keybindings = {
      "@^v" = "pasteAsPlainText:"; # cmd-ctrl-v
      "@V" = "pasteAsPlainText:"; # cmd-shift-v
      "^u" = "deleteToBeginningOfParagraph:"; # ctrl-u

      # https://gist.github.com/yujiod/9823541
      "¥" = [ "insertText:" "\\\\" ];
      "~\\\\" = [ "insertText:" "¥" ];
    };

    currentHostDefaults = {
      "com.apple.controlcenter".BatteryShowPercentage = true;
    };

    defaults = {
      # https://macos-defaults.com/
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.KeyRepeat = 4;
      NSGlobalDomain.InitialKeyRepeat = 15;
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

      # https://apple.stackexchange.com/a/424110
      # This requires to grant full disk access to the terminal!
      "com.apple.universalaccess".showWindowTitlebarIcons = true;

      # tweaks
      "com.apple.finder".QuitMenuItem = true;
      "com.apple.finder".PathBarRootAtHome = true;
      "com.apple.finder".QLEnableTextSelection = true;
      "com.apple.finder".QLHidePanelOnDeactivate = true;
      "com.apple.CrashReporter".DialogType = "none";
    };
  };

  home.activation.checkFullDiskAccess = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryBefore [ "setDarwinDefaults" "writeBoundary" ] ''
      if ! run --quiet plutil -lint /Library/Preferences/com.apple.TimeMachine.plist; then
        errorEcho "Full Disk Access is not granted to the current terminal!"
        run open "x-apple.systempreferences:com.apple.preference.security?Privacy_All"
        exit 1
      fi
    ''
  );

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

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    settings = {
      config-file = "?config.local";

      theme = "Dark Pastel";
      font-family = "UDEV Gothic 35NFLG";
      adjust-cell-height = 3;
      unfocused-split-opacity = 0.6;
      window-padding-color = "extend";
      window-padding-balance = true;
      macos-titlebar-style = "native";
      font-size = 16;
      split-divider-color = "#3f3f3f";
      quit-after-last-window-closed = true;
      window-save-state = "never";
      mouse-hide-while-typing = true;
      clipboard-paste-protection = false;
      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "no-bell,notify";
      quick-terminal-autohide = false;

      keybind = [
        "cmd+shift+equal=decrease_font_size:1"
        "cmd+\\=new_split:right"
        "cmd+shift+\\=new_split:left"
        "cmd+-=new_split:down"
        "cmd+shift+-=new_split:up"
        "cmd+h=goto_split:left"
        "cmd+j=goto_split:down"
        "cmd+k=goto_split:up"
        "cmd+l=goto_split:right"
        "global:cmd+backquote=toggle_quick_terminal"
      ];
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

    views = {
      "v1/events" = {
        sortColumn = "LAST_SEEN:asc";
        columns = [ "LAST SEEN" "TYPE" "REASON" "OBJECT" "MESSAGE" ];
      };
      "v1/containers" = {
        columns = [ "IDX" "NAME" "PF" "READY" "STATE" "RESTARTS" "AGE" "PROBES(L:R:S)" "CPU" "MEM" "CPU/RL" "MEM/RL" "%CPU/R" "%CPU/L" "%MEM/R" "%MEM/L" "PORTS" "IMAGE" ];
      };
    };

    plugins = {
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
    extraOptionOverrides = {
      # PKCS11Provider = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      ForwardAgent = "yes";
    };

    matchBlocks = {
      "*" = {
        controlPersist = "10m";
        controlMaster = "auto";
        compression = true;
      };

      home.hostname = "home.aiotter.com";
      "home.aiotter.com" = {
        match = ''host home.aiotter.com exec "${pkgs.cloudflared}/bin/cloudflared access ssh-gen --hostname %h"'';
        proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        # identityFile = "~/.cloudflared/%h-cf_key";
        # certificateFile = "~/.cloudflared/%h-cf_key-cert.pub";
      };
    };
  };

  services.pivy-agent = {
    enable = true;
    # guid = "26C3F8E165B498BCFCFE75B53683401E";  # Yubikey NEO
    guid = "E3ADCCBA7F8C7A0F2BFC6410E8566F95"; # Yubikey 5C NFC
  };
}
