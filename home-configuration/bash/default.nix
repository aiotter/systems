{ pkgs, config, ... }: {
  home.sessionVariables = {
    LESS = "--mouse --wheel-lines=3 --use-color --RAW-CONTROL-CHARS";
    MANPAGER = "less -is";
    EDITOR = "nvim";
    # HISTCONTROL = "\${HISTCONTROL:+$HISTCONTROL:}ignoredups:strip";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.bash = {
    enable = true;

    initExtra = ''
      # Load plugins
      source "${./ghq.plugin.sh}"

      bind 'set completion-ignore-case on'
      bind 'set visible-stats on'
      # bind '"\t{": complete-into-braces'

      # switch to tmux
      tmux=${pkgs.tmux}/bin/tmux
      if command -v $tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ $tmux ]] && [ -z "$TMUX" ]; then
        $tmux new-session -A -s main
      fi

      # https://github.com/akinomyoga/ble.sh/commit/021e0330d127c254560976ac208c0b39ecebc2dd
      export HISTCONTROL=ignoredups:strip
    '';

    shellAliases = {
      ls = "ls -H --color=auto";
      lg = "lazygit";
      icat = "kitty +kitten icat";
    };
  };

  # home.activation = {
  #   # Change login shell
  #   changeShell = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     if [ "$SHELL" != '${pkgs.bashInteractive}/bin/bash' ]; then
  #       $DRY_RUN_CMD chsh -s '${pkgs.bashInteractive}/bin/bash'
  #     fi
  #   '';
  # };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    # settings = lib.trivial.importTOML ./starship.toml;
  };
  xdg.configFile."starship.toml" = { source = ./starship.toml; };

  programs.blesh = {
    enable = true;
    options = {
      prompt_rps1 = "$(STARSHIP_SHELL= ${config.programs.starship.package}/bin/starship prompt --right)";
      # complete_auto_history = "";
      prompt_ps1_transient = "trim:same-dir";
      prompt_ruler = "empty-line";
      prompt_eol_mark="\\e[7m¶\\e0m";
      exec_errexit_mark="\\e[91m[EXIT %d]\\e[m";
      exec_elapsed_mark="\\e[94m[ELAPSED %s (CPU %s%%)]\\e[m";
    };
    faces = {
      auto_complete = "fg=240";
    };
    imports = [ "contrib/bash-preexec" ];
    blercExtra = ''
      function my/complete-load-hook {
        bleopt complete_auto_history=
        bleopt complete_ambiguous=
        # bleopt complete_auto_complete=
        bleopt complete_menu_maxlines=10
      };
      blehook/eval-after-load complete my/complete-load-hook
    '';
  };
}
