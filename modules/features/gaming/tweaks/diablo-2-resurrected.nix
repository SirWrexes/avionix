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
      id = "2536520";
    in
    {
      config = lib.mkIf config.gaming.tools.mangohud.enable {
        gaming.platforms.steam = {
          launchOptions.${id} = "${mangohud} %command%";
          protontricks.${id}.graphics = "wayland";
        };
      };
    };
}
