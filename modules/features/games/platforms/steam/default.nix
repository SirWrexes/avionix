{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.gaming.platforms.steam;
    in
    {
      options.gaming.platforms.steam = {
        enable = lib.mkEnableOption "Steam" // {
          default = config.programs.steam.enable;
        };
      };

      config = lib.mkIf cfg.enable {
        nixpkgs.config.allowUnfree = true;

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
