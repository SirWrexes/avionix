{ self, ... }:
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
      imports = with self.nixosModules; lib.mkIf cfg.enable [ razerbat ];
    };
}
