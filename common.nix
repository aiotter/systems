{ config, pkgs, lib, ... }:

{
  time.timeZone = "Asia/Tokyo";

  environment.systemPackages = with pkgs; [
    curl
    gcc
    git
    gnumake
    vim
    wget
  ];

  services.openssh = {
    enable = true;
    settings = {
      AllowAgentForwarding = true;
      X11Forwarding = lib.mkIf config.services.xserver.enable true;
    };
  };
}
