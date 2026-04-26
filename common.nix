{ config, pkgs, lib, ... }:
lib.mkDefault {

  time.timeZone = "Asia/Tokyo";

  environment.systemPackages = with pkgs; [
    curl
    gcc
    git
    gnumake
    vim
    wget
  ];

  environment.enableAllTerminfo = true;

  services.openssh = {
    enable = true;
    settings = {
      AllowAgentForwarding = true;
      X11Forwarding = lib.mkIf config.services.xserver.enable true;
    };
  };
}
