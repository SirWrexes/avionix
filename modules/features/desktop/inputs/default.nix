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

        # TODO: Nixify profile(s)
        # TODO: Add option to autoload profiles on session login
        services.input-remapper.enable = true;
      };
    };
}
