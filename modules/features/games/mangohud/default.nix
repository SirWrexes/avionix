{ self, inputs, ... }:
{
  flake.nixosModules.gaming = { config, pkgs, lib, ... }:
  let cfg = config.gaming.tools.mangohud; in
  {
    options.gaming.tools.mangohud.enable = lib.mkEnableOption "MangoHUD";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.mangohud ];
    };
  };

  # TODO: Make config file through nix to add implicit dependency on font (Fira NerdFont)
  perSystem = { self', pkgs, lib, ...}:
  {
    packages.mangohud = pkgs.symlinkJoin {
      name = "mangohud-wrapped";
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
