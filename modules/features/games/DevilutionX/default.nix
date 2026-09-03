{ self, inputs, ... }:
{
  flake.nixosModules.devilutionx = { config, pkgs, lib, ... }:
  {
    environment.systemPackages = [ pkgs.devilutionx ];

    systemd.user.tmpfiles.rules = let
      datadir = "%h/.local/share/diasurgical/devilution";

      packs = [
        ./DIABDAT.MPQ
        ./hellfire.mpq
        ./hfmonk.mpq
        ./hfmusic.mpq
        ./hfvoice.mpq
      ];

      packToRule = pack: "L+ ${datadir}/${builtins.baseNameOf pack} - - - - ${pack}";
    in
      [
        "d ${datadir} 0755 - - -"
      ] ++ builtins.map packToRule packs;
  };
}
