{ config, pkgs, lib, ...}:

{
  launchd.daemons."net-snmp.snmpd" = {
    serviceConfig = {
      # Disabled = true;
      # Label = "org.net-snmp.snmpd";
      Program = "/usr/sbin/snmpd";
      ProgramArguments = [ "snmpd" "-f" "-c" (toString ./snmpd.conf) ];
      KeepAlive.PathState.${builtins.storeDir} = true;
      # ServiceIPC = false;
      ProcessType = "Background";
    };
  };
}
