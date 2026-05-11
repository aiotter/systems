{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.pivy-agent;
in
{
  options.services.pivy-agent = {
    enable = mkEnableOption "pivy-agent";
    package = mkPackageOption pkgs "pivy" { };

    socket = mkOption {
      type = with types; nullOr str;
      default = "$SSH_AUTH_SOCK";
    };

    guid = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.agents.pivy-agent = {
      enable = true;
      config = {
        EnvironmentVariables.SSH_ASKPASS = toString (
          builtins.path {
            path = ./ssh-askpass;
            name = "ssh-askpass";
          }
        );

        Program = lib.getExe (
          pkgs.writeShellApplication {
            name = "pivy-agent";
            runtimeInputs = [ cfg.package ];
            text = ''
              mkdir -p "$(dirname "${cfg.socket}")"
              [[ -e "${cfg.socket}" ]] && rm -- "${cfg.socket}"
              exec pivy-agent -ig "${cfg.guid}" -a "${cfg.socket}"
            '';
          }
        );

        # Wait until Nix store is mounted
        KeepAlive.PathState.${builtins.storeDir} = true;
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/pivy-agent.log";
      };
    };

    # programs.ssh.extraOptionOverrides.IdentityAgent = cfg.socket;
  };
}
