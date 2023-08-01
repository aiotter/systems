{ pkgs, lib, config, ... }: {
  home.sessionVariables = {
    LESS = "--mouse --wheel-lines=3 --use-color --RAW-CONTROL-CHARS";
    MANPAGER = "less -isr";
    EDITOR = "nvim";
  };

  # # This one adds the path at the end of $PATH
  # home.sessionPath = [
  #   # "$HOME/.local/bin"
  # ];

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

      echo "''${PATH//:/$'\n'}" | awk -F '/' '
        /^\/nix\/store\/[a-z0-9]+-[^\/]+\/.*$/ && $4 !~ /-source$/ {
          printf "PATH added: %s\n",$0; RUN=1
        }
        END { if (RUN==1) printf "\n" }
      '
    '';

    bashrcExtra = lib.mkAfter ''
      # Add .local and .nix-profile to the top of the PATH
      export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"

      source ${pkgs.bash-preexec}/share/bash/bash-preexec.sh
    '';

    shellAliases = {
      ls = "ls -H --color=auto";
      lg = "lazygit";
      icat = "kitty +kitten icat";
    };

    sessionVariables = {
      # https://github.com/akinomyoga/ble.sh/commit/021e0330d127c254560976ac208c0b39ecebc2dd
      HISTCONTROL = "ignoredups:strip";
      HISTTIMEFORMAT = "%FT%T ";
      GOPATH = "$HOME/.go";
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
    package = pkgs.blesh.overrideAttrs (final: rec {
      version = "0.4.0-devel3";
      src = pkgs.fetchzip {
        url = "https://github.com/akinomyoga/ble.sh/releases/download/v${version}/ble-${version}.tar.xz";
        hash = "sha256-kGLp8RaInYSrJEi3h5kWEOMAbZV/gEPFUjOLgBuMhCI=";
      };
    });
    options = {
      prompt_rps1 = ''
        $(STARSHIP_SHELL= ${config.programs.starship.package}/bin/starship prompt --right \
          --terminal-width="$COLUMNS" \
          --keymap="''${KEYMAP:-}" \
          --status="$STARSHIP_CMD_STATUS" \
          --pipestatus="''${STARSHIP_PIPE_STATUS[*]}" \
          --cmd-duration="''${STARSHIP_DURATION:-}" \
          --jobs="$STARSHIP_JOBS_COUNT" \
        )
      '';
      # complete_auto_history = "";
      prompt_ps1_transient = "trim:same-dir";
      prompt_ruler = "empty-line";
    };
    faces = {
      auto_complete = "fg=240";
    };
    imports = [ "contrib/bash-preexec" ];

    blercExtra = ''
      bleopt prompt_eol_mark=$'\e[7m¶\e[m'
      bleopt exec_errexit_mark=$'\e[91m[EXIT %d]\e[m'
      bleopt exec_elapsed_mark=$'\e[94m[ELAPSED %s (CPU %s%%)]\e[m';

      function my/complete-load-hook {
        # bleopt complete_auto_history=
        bleopt complete_ambiguous=
        bleopt complete_auto_complete=
        bleopt complete_menu_maxlines=10
        bleopt complete_menu_style=align
      };
      blehook/eval-after-load complete my/complete-load-hook

      function my/overwrite-update-textmap {
        function ble/widget/.update-textmap {
          # rps1 がある時の幅の再現
          local cols=''${COLUMNS:-80} render_opts=
          # if [[ $_ble_prompt_rps1_enabled ]]; then
          #   local rps1_width=''${_ble_prompt_rps1_data[11]}
          #   render_opts=relative
          #   ((cols-=rps1_width+1,_ble_term_xenl||cols--))
          # fi

          local x=$_ble_textmap_begx y=$_ble_textmap_begy
          COLUMNS=$cols ble/textmap#update "$_ble_edit_str" "$render_opts"
        }

        function ble/prompt/unit:_ble_prompt_rps1/update {
          ble/prompt/unit/add-hash '$prompt_rps1'
          ble/prompt/unit/add-hash '$_ble_prompt_ps1_data'
          local cols=''${COLUMNS-80}
          local ps1x=''${_ble_prompt_ps1_data[3]}
          local ps1y=''${_ble_prompt_ps1_data[4]}
          local prompt_rows=$((ps1y+1)) prompt_cols=$cols
          ble/prompt/unit:{section}/update _ble_prompt_rps1 "$prompt_rps1" confine:relative:right:measure-gbox || return 1

          local esc=''${_ble_prompt_rps1_data[8]} width=
          # if [[ $esc ]]; then
          #   ((width=_ble_prompt_rps1_gbox[2]-_ble_prompt_rps1_gbox[0]))
          #   ((width&&20+width<cols&&ps1x+10+width<cols)) || esc= width=
          # fi
          _ble_prompt_rps1_data[10]=$esc
          _ble_prompt_rps1_data[11]=$width
          return 0
        }
      }
      blehook/eval-after-load keymap my/overwrite-update-textmap
    '';
  };
}
