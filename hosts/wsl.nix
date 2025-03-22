{ config, lib, pkgs, ... }:

{
  wsl = {
    enable = true;
    docker-desktop.enable = true;

    extraBin =
      let
        show-my-ip = pkgs.writeShellApplication {
          name = "show-my-ip";
          runtimeInputs = with pkgs; [ unixtools.ifconfig gnugrep gawk ];
          text = ''
            #!/bin/sh
            ifconfig eth0 | grep 'inet ' | awk '{print $2}'
          '';
        };
      in
      [{ src = "${show-my-ip}/bin/show-my-ip"; }];
  };

  # environment.etc."wsl.conf".text = ''
  #   [wsl2]
  #   networkingMode = mirrored
  # '';
}
