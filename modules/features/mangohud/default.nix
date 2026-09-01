{ self, inputs, ... }:
{
  flake.nixosModules.mangohud = { config, pkgs, lib, ... }:
  {
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.wrx-mangohud ];
  };

  perSystem = { pkgs, lib, self', ...}:
  {
    packages.wrx-mangohud = pkgs.symlinkJoin {
      name = "wrx-mangohud";
      paths = [ pkgs.mangohud ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm $out/bin/mangohud

        makeWrapper ${pkgs.mangohud}/bin/mangohud $out/bin/mangohud \
          --add-flags "--config '${./config.ini}'"
      '';
    };
  };
}
