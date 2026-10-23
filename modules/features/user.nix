{
  flake.nixosModules.user =
    {
      lib,
      config,
      options,
      ...
    }:
    let
      inherit (builtins) isNull;
      inherit (lib) mkIf mkOption types;

      cfg = config.users.user;
    in
    {
      options.users.user = mkOption {
        type = with types; nullOr options.users.users.type.nestedTypes.elemType;
        default = null;
        description = ''
          Main user of the config.
          Will take care of defining the corresponding `users.users.<name>` entry.
        '';
      };

      config = mkIf (!isNull config.users.user) {
        assertions = [
          {
            assertion = cfg ? name -> !isNull cfg.name;
            message = "Primrary user requires a name. Please set `config.user.name`.";
          }
        ];

        users.users.${config.users.user.name} = config.users.user;
      };
    };
}
