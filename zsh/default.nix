{ pkgs, lib, config, ... }: {
  home = {
    sessionVariables = {
      LESS = "--mouse --wheel-lines=3 --use-color --RAW-CONTROL-CHARS";
      MANPAGER = "less -isr";
      EDITOR = "nvim";
    };

    shellAliases = {
      icat = "kitty +kitten icat";
      lg = "lazygit";
      ls = "ls -H --color=auto";
      ls-ports = "lsof -Pi 4tcp -s TCP:LISTEN";
      rpn = "dc";
      tf = "terraform";
      update-rust = "nix build nixpkgs#rustc.unwrapped.out --out-link \${RUSTUP_HOME:-~/.rustup}/toolchains/nix";
    };
  };

  programs.zsh = {
    enable = true;

    initExtra = lib.mkAfter ''
      # Load Rust
      [[ -e "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

      # ksh emulation mode (roughly means bash emulation)
      # emulate -R ksh

      # Do not raise error on unmatched globs (implied by ksh emulation)
      unsetopt bad_pattern nomatch

      # Completion styles
      zstyle ':completion:*' menu select
      export LS_COLORS='di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
      export LSCOLORS='Exfxcxdxbxegedabagacad'
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}

      # Bind keys
      bindkey "''${terminfo[kcbt]}" reverse-menu-complete  # Shift-Tab
      bindkey \^U backward-kill-line

      # Load plugins
      source "${./ghq.plugin.sh}"
      source "${./local_history.plugin.zsh}"
      # source "$${pkgs.asdf-vm}/etc/profile.d/asdf-prepare.sh"

      # When in `nix shell` environments, print loaded PATH
      echo "''${PATH//:/$'\n'}" | awk -F '/' '
        /^\/nix\/store\/[a-z0-9]+-[^\/]+\/.*$/ && $4 !~ /-source$/ {
          printf "PATH added: %s\n",$0; RUN=1
        }
        END { if (RUN==1) printf "\n" }
      '

      # Add .local and .nix-profile to the top of the PATH
      # export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"
    '';

    profileExtra = ''
      if [[ -f "$HOME/.orbstack/shell/init.zsh" ]]; then
        source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :
      fi
    '';

    syntaxHighlighting = {
      enable = true;
      styles = {
        # path = "none";
        path_prefix = "none";
      };
    };

    shellAliases = {
      awk-csv = ''
        awk -v FPAT='([^,]*)|("[^"]+")' -v RS="\r?\n" -i <(echo '{for (i=1; i<=NF; i++) gsub(/^"|"$/, "", $i)}')
      '';
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.trivial.importTOML ./starship.toml;
  };
  # xdg.configFile."starship.toml" = { source = ./starship.toml; };
}
