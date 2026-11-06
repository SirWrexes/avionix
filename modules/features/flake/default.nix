{
  flake.nixosModules.flake =
    {
      pkgs,
      lib,
      config,
      options,
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
        host = mkOption {
          type = options.networking.hostName.type;
          default = config.networking.hostName;
          description = ''
            Target machine's name.
          '';
        };
      };

      config = {
        environment.variables = rec {
          FLAKE_HOME = "${cfg.root}";
          FLAKE_PACKAGES = "${FLAKE_HOME}#packages";
        };
      };
    };
}
