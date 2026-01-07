{
  pkgs,
  lib,
  config,
  ...
}:

let
  yamlFormat = pkgs.formats.yaml { };
in

{
  home.packages = [ pkgs.process-compose ];

  xdg.configFile."process-compose/shortcuts.yaml".source =
    yamlFormat.generate "process-compose-shortcuts"
      {
        shortcuts = {
          help.shortcut = "H";
          log_screen.shortcut = "L";
          log_follow.shortcut = "f";
          log_wrap.shortcut = "w";
          log_select.shortcut = "y";
          process_start.shortcut = "s";
          process_scale.shortcut = "S";
          process_info.shortcut = "i";
          process_stop.shortcut = "K";
          process_restart.shortcut = "r";
          process_screen.shortcut = "M";
          quit.shortcut = "q";
          find.shortcut = "F";
          find_next.shortcut = "n";
          find_prev.shortcut = "N";
          find_exit.shortcut = "Esc";
          ns_filter.shortcut = "n";
          hide_disabled.shortcut = "d";
          proc_filter.shortcut = "/";
          theme_selector.shortcut = "T";
          send_to_background.shortcut = "b";
          full_screen.shortcut = "F";
          focus_change.shortcut = "Tab";
          clear_log.shortcut = "c";
          mark_log.shortcut = "m";
          edit_process.shortcut = "e";
          term_exit.shortcut = "Ctrl-D";
          reload_config.shortcut = "R";
          dependency_graph.shortcut = "g";
        };
      };
}
