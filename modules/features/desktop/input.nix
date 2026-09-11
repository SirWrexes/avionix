{ self, inputs, ... }:
{
  flake.nixosModules.desktop = { config, pkgs, lib, ... }:
  let cfg = config.desktop; in
  {
    config = lib.mkIf cfg.enable {
      hardware.openrazer = {
        enable = true;
        users = [ "wrexes" ];
      };

      services.input-remapper.enable = true;
    };
  };
}
