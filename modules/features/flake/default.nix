{
  flake.nixosModules.flake =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        hasInfix
        mkOption
        types
        ;

      cfg = config.flake;
    in
    {
      options.flake = {
        name = mkOption {
          type = with types; addCheck str (s: !(hasInfix "\n" s));
          default = "Cool NixOS flake";
          example = "Even cooler NixOS flake";
          description = ''
            A name for your OS config flake.
          '';
        };
        root = mkOption {
          type =
            with types;
            pathWith {
              inStore = false;
              absolute = true;
            };
          default = "/etc/nixos";
          example = "/home/user/.nixos";
          description = ''
            Absolute path to your flake's root directory.
          '';
        };
        self = mkOption {
          type = with types; lazyAttrsOf anything;
          description = ''
            Your flake's `self`.
            This option doesn't do any type checking.
            Behaviour is you provide it with anything else than your flake's `self` is undefined.
          '';
        };
      };

      config =
        let
          FLAKE_HOME = "${cfg.root}";
        in
        {
          environment.variables = {
            inherit FLAKE_HOME;
            FLAKE_PACKAGES = "${FLAKE_HOME}#packages";
          };

          environment.sessionVariables.NIX_CONF_DIR = FLAKE_HOME;
        };
    };
}
