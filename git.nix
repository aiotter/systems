{ pkgs, lib, ... }:

let
  git = pkgs.git.overrideAttrs (old: rec {
    version = "2.55.0";
    src = pkgs.fetchurl {
      url = "https://www.kernel.org/pub/software/scm/git/git-${version}.tar.xz";
      hash = "sha256-RX/bBNyHKOAH1GiGleaRLm9oByeSDypAvxHqzBdQU1c=";
    };

    patches = lib.filter (p: !(lib.hasInfix "expect-gui--askyesno" (toString p))) old.patches;

    makeFlags = old.makeFlags ++ [ "NO_RUST=1" ];
  });

  gitCustom = git.override {
    withManual = true;
    osxkeychainSupport = false;
    pythonSupport = false;
    perlSupport = false;
    # rustSupport = false;
    withpcre2 = false;
  };
in

{
    gh
    ghq
    git-filter-repo
    tig
  ];

  programs.git = {
    enable = true;
    package = gitCustom;

    lfs.enable = true;
    xet.enable = true;

    settings = {
      user = {
        name = "aiotter";
        email = "git@aiotter.com";
        useConfigOnly = true;
      };

      alias = {
        delete-merged = ''!f() { git branch --merged ''${1:-master} | grep -v "^[ *]*''${1:-master}$" | xargs git branch -d; }; f'';
        delete-squashed = ''
          !f() { local targetBranch=''${1:-master} && git checkout -q $targetBranch && git branch --merged | grep -v \"\\*\" | xargs -n 1 git branch -d && git for-each-ref refs/heads/ \"--format=%(refname:short)\" | while read branch; do mergeBase=$(git merge-base $targetBranch $branch) && [[ $(git cherry $targetBranch $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == \"-\"* ]] && git branch -D $branch; done; }; f
        '';
        fpush = "push --force-with-lease";
        get = "!ghq get";
        # graph = "log --graph --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s (%cr) %C(blue)<%an>%Creset' --abbrev-commit --date=relative";
        graph = "!${lib.getExe pkgs.serie}";
        list = "!ghq list";
        one = "!git log --oneline --color=always | head";
        root = "rev-parse --show-toplevel";
        sync = "!git fetch && git reset --hard origin/$(git branch --show-current)";
        unstage = "reset HEAD";
      };

      pull.ff = "only";
      rebase.autosquash = true;
      commit.verbose = true;
      log.date = "iso";

      # Suppress warning on `git diff --check`
      core.whitespace = "-space-before-tab";

      ghq = {
        root = "~/repo";
        user = "aiotter";
      };
      credential."https://github.com".helper = "${pkgs.gh}/bin/gh auth git-credential";
      url."git@github.com".pushInsteadOf = [
        "git://github.com/"
        "https://github.com/"
      ];

      color = {
        diff = {
          old = "#005099 normal strike";
          new = "normal normal bold";
        };
      };
    };

    ignores = [
      "*.swp"
      "*.bak"
      "*~"
      ".DS_Store"

      # General development
      ".direnv/"
      ".env"
      ".envrc"

      # Python
      "*.egg-info/"
      ".ipynb_checkpoints"
      ".ropeproject"
      ".venv"
      "__pycache__/"
      "build/"
      "develop-eggs/"
      "dist/"
      "wheels/"

      # IntelliJ
      ".idea/"
    ];
  };

  programs.delta = {
    enable = true;
    # enableGitIntegration = true;
    options = {
      features = "traditional";
      traditional = {
        keep-plus-minus-markers = true;
        minus-style = "syntax dim strike \"#001930\"";
        minus-non-emph-style = "syntax dim strike \"#001930\"";
        minus-emph-style = "syntax strike \"#005099\"";
        plus-emph-style = "auto bold auto";
      };
      side-by-side = {
        side-by-side = true;
        line-numbers = true;
        minus-style = "syntax dim strike \"#001930\"";
        minus-emph-style = "syntax bold \"#005099\"";
        plus-emph-style = "auto bold auto";
      };
    };
  };

  programs.mergiraf = {
    enable = true;
    # enableGitIntegration = true;
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options = {
      sort-paths = true;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      customCommands = [
        {
          key = "E";
          context = "commits";
          description = "Open editor and start interactive rebase";
          command = "git rebase -i {{.SelectedLocalCommit.Hash}}~";
          output = "terminal";
        }
      ];
      gui = {
        theme = {
          activeBorderColor = [
            "yellow"
            "bold"
          ];
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
        pagers = [
          {
            externalDiffCommand = "difft --color=always --sort-paths";
          }
          {
            pager = "delta --paging=never --features=traditional --minus-style='\"#606060\" \"#001930\"'";
          }
        ];
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

      keybinding = {
        universal = {
          copyToClipboard = "C";
          fetch = "f";
        };
      };
    };
  };
}
