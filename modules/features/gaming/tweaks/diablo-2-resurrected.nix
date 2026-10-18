{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (config.gaming.tools) mangohud;

      id = "2536520";
    in
    {
      config = {
        programs.steam = {
          launchOptions.${id} = lib.mkIf mangohud.enable "mangohud %command%";
          protontricks.settings.${id}.graphics = "wayland";
        };
      };
    };
}
