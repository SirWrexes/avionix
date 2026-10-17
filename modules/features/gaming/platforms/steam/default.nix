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

      cfg = config.gaming.platforms.steam;
    in
    {
      options.gaming.platforms.steam = {
        enable = lib.mkEnableOption "Steam" // {
          default = config.programs.steam.enable;
        };

        steamDir = lib.mkOption {
          type = with types; str;
          default = "${userHome}/.steam/steam";
        };

        steamAppsDir = lib.mkOption {
          type = with types; str;
          default = "${cfg.steamDir}/steamapps";
          readOnly = true;
        };
      };

      config = lib.mkIf (cfg.enable || config.programs.steam.enable) {
        programs.steam = {
          enable = true;
          protontricks.enable = true;
          remotePlay.openFirewall = true;
        };

        programs.gamemode.enable = true;
        programs.gamescope.enable = true;
      };
    };
}
