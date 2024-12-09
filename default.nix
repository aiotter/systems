{ config, pkgs, lib, ... }:

{
  # imports = [ <home-manager/nix-darwin> ];
  imports = [
    modules/snmp
  ];

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      bash-prompt = [nix]\W$ 
      warn-dirty = false
    '';
    settings = {
      sandbox = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://aiotter.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "aiotter.cachix.org-1:YaYTZbiaiBIUYsJPwhcgG9yXXWd15xPtGmvq7DEmKnE="
      ];
    };
  };

  environment.shellInit = ''
    # Load HomeManager
    [ -e ~/.nix-profile/etc/profile.d/hm-session-vars.sh ] \
      && source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    [ -e /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ] \
      && source /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
  '';

  environment.systemPath = [
    "/opt/homebrew/bin"
  ];

  # environment.shells = [ "${pkgs.bashInteractive}/bin/bash" ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/path/to/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.cachix
    # pkgs.home-manager
    pkgs.bashInteractive
    pkgs.bash-completion
    pkgs.git
    pkgs.vim
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon = {
    enable = true;
    logFile = "/var/log/nix-daemon.log";
  };

  # Cachix deploy
  # services.cachix-agent.enable = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  # programs.fish.enable = true;
  programs.bash = {
    enable = true;
    completion.enable = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # create locate database
  launchd.daemons.locate = {
    command = "/usr/libexec/locate.updatedb";
    serviceConfig = {
      ProcessType = "Background";
      KeepAlive.PathState."/var/db/locate.database" = false;
      StartCalendarInterval = [{
        Hour = 3;
        Minute = 15;
        Weekday = 6;
      }];
      AbandonProcessGroup = true;
    };
  };

  homebrew = {
    enable = true;
    # onActivation.autoUpdate = true;
    brews = [
      "mackup"
      "telnet"
    ];
    casks = [
      "alt-tab"
      "betterdisplay"
      "google-japanese-ime"
      "karabiner-elements"
      "launchcontrol"
      "lunar"
      "raycast"
      "ubersicht"
    ];
    masApps = {
      # ColorBlindPal = 1023111433;
      "Day One" = 1055511498;
      # "Countdown Timer Plus" = 1150771803;
      # "AmorphousDiskMark: benchmark storage devices" = 1168254295;
      # DaltonLens = 1222737651;
      Bitwarden = 1352778147;
      "AdGuard for Safari" = 1440147259;
      Hush = 1544743900;
      GoodNotes = 1444383602;
      "Hidden bar" = 1452453066;
      "Tab Closer: close multiple tabs once on Safari" = 1485958094;
      "Keepa - Price Tracker" = 1533805339;
      "Raindrop.io" = 1549370672;
      Telephone = 406825478;
      "LadioCast: sound mixer" = 411213048;
      LilyView = 529490330;
      # "Amphetamine: prevent sleeping" = 937984704;
    };
  };
}
