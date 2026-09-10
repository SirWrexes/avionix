{ self, inputs, ... }:
{
  flake.nixosModules.steam = { config, pkgs, lib, ... }:
  {
    nixpkgs.config.allowUnfree = true;

    programs.steam = {
      enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;
  };
}
