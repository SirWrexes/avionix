{ self, inputs, ... }:
{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      config = lib.mkIf config.gaming.tools.mangohud.enable {
        gaming.platforms.steam.launchOptions."2536520" = "${
          lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.mangohud
        } %command%";
      };
    };
}
