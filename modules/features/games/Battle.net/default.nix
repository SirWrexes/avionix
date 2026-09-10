/*
    Since there's no NixOS package to install Battle.net, the next best reproducible option IMO is to do it with Lutris.
    This module will make Battle.net available as a desktop application, launched with Lutris under the hood.
    If not already installed on the system, Lutris will launch the installer instead.
*/
{ self, inputs, ... }:
{
  flake.nixosModules.gaming = { config, pkgs, lib, ... }:
  let cfg = config.gaming.platforms.battlenet; in
  {
    options.gaming.platforms.battlenet.enable = lib.mkEnableOption "Battle.net";

    config = lib.mkIf cfg.enable {
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.battle-net ];
    };
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
