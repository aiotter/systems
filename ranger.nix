{
  pkgs,
  lib,
  config,
  ...
}:

let
  ranger = config.programs.ranger.package;
  previewer = pkgs.writeShellScript "previewer" ''
    ## Script arguments
    FILE_PATH="$1"         # Full path of the highlighted file
    PV_WIDTH="$2"          # Width of the preview pane (number of fitting characters)
    PV_HEIGHT="$3"         # Height of the preview pane (number of fitting characters)
    IMAGE_CACHE_PATH="$4"  # Full path that should be used to cache image preview
    PV_IMAGE_ENABLED="$5"  # 'True' if image previews are enabled, 'False' otherwise.

    mime_type=$("${lib.getExe pkgs.file}" --dereference --brief --mime-type "$FILE_PATH")

    case "$mime_type" in
      image/*)
        "${ranger}"/lib/python*/site-packages/ranger/data/scope.sh "$@"
        exit $?
        ;;

      *)
        env COLORTERM=8bit "${lib.getExe pkgs.bat}" --color=always --style=changes --decorations=always --terminal-width="$PV_WIDTH" "$FILE_PATH" && exit 5
        ;;
    esac
  '';
in

{
  programs.ranger = {
    enable = true;

    # Use the latest source to support Ghostty
    # https://github.com/ranger/ranger/pull/3036
    package = pkgs.ranger.overridePythonAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "ranger";
        repo = "ranger";
        rev = "08913377c968d39f11fa2d546aa8d53a99bb5e98";
        hash = "sha256-vn1rAOFB2vq04Y/WAE44iH/b/zamAmvq8putUKwNqR8=";
      };
    };

    aliases = {
      mv = "rename";
      rm = "delete";
    };

    mappings = {
      "<c-j>" = "display_file";
      "<down>" = "scroll_preview 3";
      "<up>" = "scroll_preview -3";
      O = "shell -f open %d";
      e = "edit";
    };

    settings = {
      draw_borders = "both";
      mouse_enabled = false;
      preview_images = true;
      preview_images_method = "kitty";
      use_preview_script = true;
      preview_script = "${previewer}";
    };

    extraConfig = ''
      default_linemode devicons
      unmap <alt>r <alt>l <alt><right> <alt><left> <right> <left>
    '';

    # https://github.com/ranger/ranger/wiki/Plugins
    plugins = [
      {
        name = "ranger_devicons";
        src = pkgs.fetchFromGitHub {
          owner = "alexanderjeurissen";
          repo = "ranger_devicons";
          rev = "1bcaff0366a9d345313dc5af14002cfdcddabb82";
          hash = "sha256-qvWqKVS4C5OO6bgETBlVDwcv4eamGlCUltjsBU3gAbA=";
        };
      }
      {
        name = "ranger-gitplug.py";
        src = pkgs.fetchurl {
          url = "https://github.com/DogeTheBeast/ranger-gitplug/raw/ecca42ede725543032838392a38ba0b533f637dd/gitplug.py";
          hash = "sha256-Y8+wDCxgBagv3VPh3QUNU0yRqRW8rd80YL4XdBvCIe8=";
        };
      }
    ];
  };
}
