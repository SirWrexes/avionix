{ dirs, ... }:
let
  mpqs = [
    "DIABDAT.MPQ"
    "hellfire.mpq"
    "hfmonk.mpq"
    "hfmusic.mpq"
    "hfvoice.mpq"
  ];

  mpqSecrets = builtins.listToAttrs (
    builtins.map (file: rec {
      name = "devilutionx/${file}";
      value.file = "${dirs.secrets}/${name}.age";
    }) mpqs
  );
in
{
  flake.nixosModules.artemis = { lib, config, ... }: {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    age.secrets = mpqSecrets;

    gaming = {
      tools.mangohud.enable = true;

      platforms.battlenet.enable = true;

      games.devilutionx = {
        # enable = true;
        gameFiles = lib.mapAttrsToList (name: path: config.age.secrets.${name}.path) mpqSecrets;
      };
    };
  };
}
