{
  flake.nixosModules.hosts =
    { lib, config, ... }:
    lib.mkIf (config.host == "artemis" && false) {
      programs.steam = {
        enable = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true;
      };

      programs.battlenet.enable = true;
      programs.mangohud.enable = true;
      programs.gamemode.enable = true;
      programs.gamescope.enable = true;
    };
}
