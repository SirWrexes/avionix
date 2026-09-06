{ self, inputs, ... }:
{
  flake.nixosModules.mangohud = { config, pkgs, lib, ... }:
  {
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.wrx-mangohud ];
  };

  perSystem = { self', pkgs, lib, ...}:
  {
    packages.wrx-mangohud = pkgs.symlinkJoin {
      name = "wrx-mangohud";
      paths = [ pkgs.mangohud ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm $out/bin/mangohud
        rm $out/bin/mangoapp

        makeWrapper ${pkgs.mangohud}/bin/mangohud $out/bin/mangohud \
          --set-default MANGOHUD_CONFIGFILE '${./config.ini}'

        makeWrapper ${pkgs.mangohud}/bin/mangoapp $out/bin/mangoapp \
          --set-default MANGOHUD_CONFIGFILE '${./config.ini}'
      '';
    };
  };
}
