{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.yubikey-agent;
in
{
  options.services.pivy-agent = {
    enable = mkEnableOption "yubikey-agent";
    package = mkPackageOption pkgs "yubikey-agent" { };

    socket = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.cache/yubikey-agent/agent.sock";
    };
  };

  config = mkIf cfg.enable {
    launchd.agents.pivy-agent = {
      enable = true;
      config = {
        ProgramArguments = [
          (cfg.package + /bin/yubikey-agent)
          "-l"
          cfg.socket
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/yubikey-agent.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/yubikey-agent.log";
      };
    };

    programs.ssh.extraOptionOverrides.IdentityAgent = cfg.socket;

    programs.bash.sessionVariables.SSH_AUTH_SOCK = cfg.socket;
  };
}
