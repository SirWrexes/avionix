{ self, inputs, ... }:
{
  flake.nixosModules.steam = { config, pkgs, lib, ... }:
  {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;
  };
}
