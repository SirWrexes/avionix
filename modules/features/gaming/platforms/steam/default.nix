{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) types;

      userName = config.core.user.name;
      userHome = config.users.users.${userName}.home;

      cfg = config.programs.steam;
    in
    {
      options.programs.steam = {
        dirs = {
          steam = lib.mkOption {
            type = with types; str;
            default = "${userHome}/.steam/steam";
          };
          steamapps = lib.mkOption {
            type = with types; str;
            default = "${cfg.dirs.steam}/steamapps";
            readOnly = true;
          };
        };
      };
    };
}
