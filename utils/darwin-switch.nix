{ pkgs, darwinConfiguration }:

pkgs.writeShellApplication {
  name = "darwin-rebuild-switch";
  # runtimeInputs = [];
  text = ''
    systemConfig="${darwinConfiguration.system}"
    profile="${darwinConfiguration.config.system.profile}"

    if [ "$USER" != root ] && [ ! -w "$(dirname "$profile")" ]; then
      sudo -H nix-env -p "$profile" --set "$systemConfig"
    else
      nix-env -p "$profile" --set "$systemConfig"
    fi

    "$systemConfig/activate-user"

    if [ "$USER" != root ]; then
      sudo "$systemConfig/activate"
    else
      "$systemConfig/activate"
    fi
  '';
}
