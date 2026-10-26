{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) mkIf;
      inherit (config.programs) mangohud;
    in
    mkIf (config.host == "artemis" && false) {
      programs.steam.apps."2536520" = {
        launchOptions.text = mkIf mangohud.enable "mangohud %command%";
        protontricks.settings.graphics = "wayland";
      };
    };
}
