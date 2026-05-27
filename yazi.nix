{
  pkgs,
  lib,
  config,
  ...
}:

let
  pluginListToAttrs =
    plugins:
    map (plugin: {
      name = plugin.pname |> lib.removeSuffix ".yazi";
      value = plugin;
    }) plugins
    |> lib.listToAttrs;

  bashIntegration = ''
    function ${config.programs.yazi.shellWrapperName}() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      command yazi "$@" --cwd-file="$tmp"
      if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        # builtin cd -- "$cwd"
        builtin pushd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';
in

{
  programs.yazi = {
    enable = true;

    shellWrapperName = "yazi";
    enableZshIntegration = false;
    enableBashIntegration = false;

    plugins =
      with pkgs.yaziPlugins;
      [
        chmod
        full-border
        git
        smart-enter
      ]
      |> pluginListToAttrs;

    initLua = ''
      require("full-border"):setup()
      require("git"):setup()
    '';

    settings = {
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
          }
          {
            id = "git";
            url = "*/";
            run = "git";
          }
        ];
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "<Enter>";
          run = "plugin smart-enter";
        }
        {
          on = "q";
          run = "quit --no-cwd-file";
          desc = "Quit without outputting cwd-file";
        }
        {
          on = "Q";
          run = "quit";
          desc = "Quit the process";
        }
        {
          on = "e";
          run = "shell --block -- $EDITOR %h";
          desc = "Edit hovered file with $EDITOR";
        }
        {
          on = [ "c" "m" ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };
  };

  programs.bash.initExtra = lib.mkIf config.home.shell.enableBashIntegration bashIntegration;
  programs.zsh.initContent = lib.mkIf config.home.shell.enableZshIntegration bashIntegration;
}
