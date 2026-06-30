# This module performs the declarative equivalent of `git xet install`.
{
  config,
  lib,
  pkgsUnstable,
  ...
}:

let
  cfg = config.programs.git;
in
{
  options.programs.git.xet = {
    enable = lib.mkEnableOption "git-xet support for Git LFS";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgsUnstable.git-xet;
      defaultText = lib.literalExpression "pkgs.git-xet";
      description = "Package providing the git-xet executable.";
    };
  };

  config = lib.mkIf (config.programs.git.enable && cfg.xet.enable) {
    home.packages = lib.mkIf (cfg.xet.package != null) [ cfg.xet.package ];

    programs.git = {
      lfs.enable = true;

      settings = {
        "lfs.customtransfer.xet" = {
          path = if cfg.xet.package != null then lib.getExe cfg.xet.package else "git-xet";
          args = "transfer";
          concurrent = true;
        };
      };
    };
  };
}
