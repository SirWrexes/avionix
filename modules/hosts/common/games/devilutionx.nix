{ dirs, ... }:
let
  inherit (builtins) listToAttrs map;

  mpqs = [
    "DIABDAT.MPQ"
    "hellfire.mpq"
    "hfmonk.mpq"
    "hfmusic.mpq"
    "hfvoice.mpq"
  ];

  secrets = listToAttrs (
    map (file: rec {
      name = "devilutionx/${file}";
      value.file = "${dirs.secrets}/${name}.age";
    }) mpqs
  );
in
{
  flake.nixosModules.hosts =
    { lib, config, ... }:
    lib.mkIf false {
      age = { inherit secrets; };

      games.devilutionx.gameFiles = lib.mapAttrsToList (
        name: path: config.age.secrets.${name}.path
      ) secrets;
    };
}
