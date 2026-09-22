{ self, inputs, ... }:
{
  flake.nixosModules.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.desktop;
    in
    {
      imports = [ self.nixosModules.razerbat ];

      config = lib.mkIf cfg.enable {
        hardware.openrazer = {
          enable = true;
          users = [ config.core.user.name ];
        };

        services.input-remapper.enable = true;
      };
    };
}
