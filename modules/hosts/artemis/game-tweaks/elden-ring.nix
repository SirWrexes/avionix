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
      programs.modEngine3 = {
        enable = true;
        package = pkgs.writeShellApplication {
          name = "me3";
          runtimeInputs = [ pkgs.me3 ];
          # Originally, it uses its own command and `steam-run` to start the game with injected mods.
          # That's fine until you realise it discards all launch options.
          # So I wrapped the package so that the command gets launched with the same options and wrappers, and the game inherits them.
          text = ''
            ${mergedOptions} me3 "$@"
          '';
        };
      };

      programs.steam.apps."1245620" = {
        launchOptions.text = "${mergedOptions} %command%";
        protontricks.settings = {
          grabfullscreen = true;
          graphics = "wayland";
        };
      };
    };
}
