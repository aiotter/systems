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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
