{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    lib.mkIf (config.host == "artemis") {
      programs = {
        steam = {
          enable = true;
          protontricks.enable = true;
          remotePlay.openFirewall = true;
        };

        battlenet.enable = true;
        mangohud.enable = true;
        gamemode.enable = true;
        gamescope.enable = true;
      };
    };
}
