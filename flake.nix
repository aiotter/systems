{
  outputs = { self }: {
    lib = {
      consts = {
        ssh-key = "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBC989H9RvLj9r2nxqj5cS8pN0fvcglmY/C/4bVbkOXufyMMvujbDr4ME5ba3rxsLJySavmkXtYt1v5+wDTiFC1gNHsIx3FYpI71hF61tWg/SpuIoOMyI82smszaFHq/eXw== aiotter@yubikey5c";
      };
    };

    nixosModules = {
      default = _: with self.nixosModules; {
        imports = [ flakes caches ];
      };

      flakes = _: {
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
      };

      caches = _: {
        nix.settings = {
          substituters = [
            "https://nix-community.cachix.org"
            "https://aiotter.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "aiotter.cachix.org-1:YaYTZbiaiBIUYsJPwhcgG9yXXWd15xPtGmvq7DEmKnE="
          ];
        };
      };
    };
  };
}
