{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.pivy-agent;
in
{
  options.services.pivy-agent = {
    enable = mkEnableOption "pivy-agent";
    package = mkPackageOption pkgs "pivy" { };

    replaceSystemAgent = mkOption {
      type = types.bool;
      default = pkgs.stdenv.isDarwin;
      defaultText = lib.literalExpression "pkgs.stdenv.isDarwin";
      description = "Whether to use the system SSH agent socket on Darwin.";
    };

    socket = mkOption {
      type = with types; nullOr str;
      default = null;
      description = ''
        Explicit socket path for pivy-agent.

        If null and replaceSystemAgent is false, the module uses
        `''${config.xdg.cacheHome}/pivy-agent/agent.sock`.

        This option cannot be used together with replaceSystemAgent.
      '';
    };

    guid = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin || !cfg.replaceSystemAgent;
        message = "programs.pivy-agent.replaceSystemAgent can only be enabled on Darwin.";
      }
      {
        assertion = !(cfg.replaceSystemAgent && cfg.socket != null);
        message = "programs.pivy-agent.socket and programs.pivy-agent.replaceSystemAgent cannot be used together.";
      }
    ];

    launchd.agents.pivy-agent = {
      enable = true;
      config = {
        EnvironmentVariables =
          optionalAttrs (!cfg.replaceSystemAgent) {
            SSH_AUTH_SOCK = defaultTo "${config.xdg.cacheHome}/pivy-agent/agent.sock" cfg.socket;
          }
          // {
            SSH_ASKPASS = toString (
              builtins.path {
                path = ./ssh-askpass;
                name = "ssh-askpass";
              }
            );
          };

        Program = lib.getExe (
          pkgs.writeShellApplication {
            name = "pivy-agent";
            runtimeInputs = [ cfg.package ];
            text = ''
              if [[ -z "''${SSH_AUTH_SOCK:-}" ]]; then
                echo "SSH_AUTH_SOCK is not set" >&2
                exit 1
              fi

              mkdir -p "$(dirname "$SSH_AUTH_SOCK")"
              [[ -e "$SSH_AUTH_SOCK" ]] && rm -- "$SSH_AUTH_SOCK"
              exec pivy-agent -ig ${lib.escapeShellArg cfg.guid} -a "$SSH_AUTH_SOCK"
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
