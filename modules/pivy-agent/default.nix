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
      type = types.str;
      default = "${config.home.homeDirectory}/.cache/pivy-agent/agent.sock";
    };

    guid = mkOption {
      type = types.str;
    };
  };

  config = {
    launchd.agents.pivy-agent = {
      enable = true;
      config = {
        EnvironmentVariables.SSH_ASKPASS = toString ./ssh-askpass;
        ProgramArguments = [
          (cfg.package + /bin/pivy-agent)
          "-ig"
          cfg.guid
          "-a"
          cfg.socket
        ];
        # Wait until Nix store is mounted
        KeepAlive.PathState.${builtins.storeDir} = true;
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/pivy-agent.log";
      };
    };

    programs.ssh.extraOptionOverrides.IdentityAgent = cfg.socket;

    programs.bash.sessionVariables.SSH_AUTH_SOCK = cfg.socket;
  };
}
