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
    in
    {
      config = {
        programs.steam.apps."2536520" = {
          launchOptions.text = lib.mkIf mangohud.enable "mangohud %command%";
          protontricks.settings.graphics = "wayland";
        };
      };
    };
}
