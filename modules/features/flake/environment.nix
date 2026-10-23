{
  flake.nixosModules.flake =
    { lib, config, ... }:
    let
      inherit (lib) mkOption types;

      cfg = config.flake;
    in
    {
      options.flake = {
        root = mkOption {
          type =
            with types;
            pathWith {
              inStore = false;
              absolute = true;
            };
          default = "${config.users.user.home}/.config/nixos";
        };
      };

      config = {
        environment.sessionVariables = rec {
          FLAKE_HOME = "${cfg.root}";
          FLAKE_PACKAGES = "${FLAKE_HOME}#packages";
          NIX_CONF_DIR = FLAKE_HOME;
        };
      };
    };
}
