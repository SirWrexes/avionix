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

      id = "1245620";

      gamemode = lib.getExe config.programs.gamemode.package;
      mangohud = lib.getExe self.packages.${system}.mangohud;

      env = builtins.concatStringsSep " " ([
        "PROTON_ENABLE_WAYLAND=1"
        "PROTON_FORCE_LARGE_ADDRESS_AWARE=1"
        "PROTON_NO_WM_DECORATION=1"
      ]);
    in
    {
      gaming.platforms.steam = {
        protontricks.${id}.grabfullscreen = true;
        launchOptions.${id} = ''
          ${env} ${lib.optionalString config.gaming.tools.mangohud.enable mangohud} ${gamemode} %command%
        '';
      };
    };
}
