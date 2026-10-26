{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (builtins)
        concatStringsSep
        ;

      inherit (lib)
        mkIf
        optional
        ;

      inherit (config.programs)
        gamemode
        mangohud
        ;

      env = [
        ''PROTON_ENABLE_WAYLAND="1"''
        ''PROTON_FORCE_LARGE_ADDRESS_AWARE="1"''
        ''PROTON_NO_WM_DECORATION="1"''
      ];

      wrappers = (optional mangohud.enable "mangohud") ++ (optional gamemode.enable "gamemoderun");

      mergedOptions = concatStringsSep " " (env ++ wrappers);
    in
    mkIf (config.host == "artemis") {
      programs.steam.apps."1245620" = {
        launchOptions.text = "${mergedOptions} %command%";
        protontricks.settings = {
          grabfullscreen = true;
          graphics = "wayland";
        };
      };
    };
}
