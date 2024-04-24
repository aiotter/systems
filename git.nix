{ pkgs, config, ... }:

{
  programs.git = {
    enable = true;

    userName = "aiotter";
    userEmail = "git@aiotter.com";

    aliases = {
      fpush = "push --force-with-lease";
      get = "!ghq get";
      graph = "log --graph --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s (%cr) %C(blue)<%an>%Creset' --abbrev-commit --date=relative";
      list = "!ghq list";
      one = "!git log --oneline --color=always | head";
      unstage = "reset HEAD";
      delete-squashed = ''
        !f() { local targetBranch=''${1:-master} && git checkout -q $targetBranch && git branch --merged | grep -v \"\\*\" | xargs -n 1 git branch -d && git for-each-ref refs/heads/ \"--format=%(refname:short)\" | while read branch; do mergeBase=$(git merge-base $targetBranch $branch) && [[ $(git cherry $targetBranch $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == \"-\"* ]] && git branch -D $branch; done; }; f
      '';
    };

    delta = {
      enable = true;
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

    ignores = [
      "*.swp"
      "*~"
      ".DS_Store"

      # General development
      ".direnv/"
      ".env"

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

    extraConfig = {
      user.useConfigOnly = true;
      rebase.autosquash = true;
      commit.verbose = true;
      log.date = "iso";
      ghq = {
        root = "~/repo";
        user = "aiotter";
      };
      credential."https://github.com".helper = "${pkgs.gh}/bin/gh auth git-credential";
    };
  };

  home.packages = with pkgs; [ gh ];
}
