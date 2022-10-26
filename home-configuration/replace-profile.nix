{ lib, config, ... }:
let
  cfg = config.home;
in
{
  home.activation.installPackages = lib.mkForce (lib.hm.dag.entryAfter [ "writeBoundary" ] (
    if config.submoduleSupport.externalPackageInstall
    then
      ''
        if [[ -e "$nixProfilePath"/manifest.json ]] ; then
          nix profile list \
            | { grep 'home-manager-path$' || test $? = 1; } \
            | awk -F ' ' '{ print $4 }' \
            | cut -d ' ' -f 4 \
            | xargs -t $DRY_RUN_CMD nix profile remove $VERBOSE_ARG
        else
          if nix-env -q | grep '^home-manager-path$'; then
            $DRY_RUN_CMD nix-env -e home-manager-path
          fi
        fi
      ''
    else
      ''
        function hm-internal-replace-profile {
          nix profile list \
            | { grep 'home-manager-path$' || test $? = 1; } \
            | awk -F ' ' '{ print $4 }' \
            | cut -d ' ' -f 4 \
            | xargs -t $DRY_RUN_CMD nix profile remove $VERBOSE_ARG
          $DRY_RUN_CMD nix profile install $1
        }
        if [[ -e "$nixProfilePath"/manifest.json ]] ; then
          INSTALL_CMD="hm-internal-replace-profile"
          LIST_CMD="nix profile list"
          REMOVE_CMD_SYNTAX='nix profile remove {number | store path}'
        else
          INSTALL_CMD="nix-env -i"
          LIST_CMD="nix-env -q"
          REMOVE_CMD_SYNTAX='nix-env -e {package name}'
        fi
        if ! $DRY_RUN_CMD $INSTALL_CMD ${cfg.path} ; then
          echo
          _iError $'Oops, Nix failed to install your new Home Manager profile!\n\nPerhaps there is a conflict with a package that was installed using\n"%s"? Try running\n\n    %s\n\nand if there is a conflicting package you can remove it with\n\n    %s\n\nThen try activating your Home Manager configuration again.' "$INSTALL_CMD" "$LIST_CMD" "$REMOVE_CMD_SYNTAX"
          exit 1
        fi
        unset INSTALL_CMD LIST_CMD REMOVE_CMD_SYNTAX
      ''
  ));
}
