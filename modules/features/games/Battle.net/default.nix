/*
    Since there's no NixOS package to install Battle.net, the next best option IMO is to do it with Lutris.
    This module will make Battle.net available as a desktop application, and Lutris will take care of installing
    it if it is not already, otherwise it'll simply launch it.
*/
{ self, inputs, ... }:
{
  flake.nixosModules.battlenet = { config, pkgs, lib, ... }:
  {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.battle-net ];
  };

  perSystem = { self', lib, config, system, ... }:
  let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-unwrapped"
      ];
    };
  in {
    packages.battle-net = pkgs.makeDesktopItem {
      name = "battle-net";
      desktopName = "Battle.net";
      comment = "Blizzard's online gaming and social platform";
      exec = "${lib.getExe pkgs.lutris} lutris:battlenet";
      icon = ./icon.png;
      categories = [ "Game" ];
    };
  };
}
