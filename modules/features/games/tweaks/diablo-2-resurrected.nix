{ self, ... }:
{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (config.core) system;

      mangohud = lib.getExe self.packages.${system}.mangohud;
    in
    {
      config = lib.mkIf config.gaming.tools.mangohud.enable {
        gaming.platforms.steam.launchOptions."2536520" = "${mangohud} %command%";
      };
    };
}
