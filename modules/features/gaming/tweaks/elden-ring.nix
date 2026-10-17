{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (config.programs) gamemode;
      inherit (config.gaming.tools) mangohud;

      id = "1245620";

      env = [
        ''PROTON_ENABLE_WAYLAND="1"''
        ''PROTON_FORCE_LARGE_ADDRESS_AWARE="1"''
        ''PROTON_NO_WM_DECORATION="1"''
      ];

      launchOptions =
        env ++ (optional mangohud.enable "mangohud") ++ (optional gamemode.enable "gamemoderun");

      mergedOptions = concatStringsSep " " launchOptions;

    in
    {
      gaming.platforms.steam = {
        protontricks.${id}.grabfullscreen = true;
        launchOptions.${id} = "${mergedOptions} %command%";
      };
    };
}
