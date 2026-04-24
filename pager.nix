{ pkgsUnstable, lib, ... }:

let
  inherit (pkgsUnstable) ov;
in

{
  home = {
    packages = [ ov ];

    sessionVariables = {
      PAGER = lib.getExe ov;
      MANPAGER = lib.getExe ov;
    };
  };

  xdg.configFile."ov/config.yaml".text = builtins.toJSON {
    KeyBind = {
      down = [ "Down" "ctrl+n" "j" ];
      up = [ "Up" "ctrl+p" "k" ];
      page_down = [ "PageDown" "ctrl+f" ];
      page_up = [ "PageUp" "ctrl+b" ];
      bottom = [ "End" "G" ];

      jump_target = [ "J" ];
      follow_mode = [ "alt+f" ];
      align_format = [ "alt+shift+f" ];
      line_number_mode = [ "alt+n" ];
    };
  };
}
