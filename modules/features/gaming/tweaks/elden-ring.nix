{
  flake.nixosModules.gaming =
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
        concatMapStringsSep
        optional
        ;

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

      me3 = pkgs.writeShellApplication {
        name = "me3";
        runtimeInputs = [ pkgs.me3 ];
        text = ''
          ${concatMapStringsSep "\n" (kvp: "export ${kvp}") env}
          ${concatStringsSep " " (
            (optional mangohud.enable "mangohud")
            ++ (optional gamemode.enable "gamemoderun")
            ++ [ ''me3 "$@"'' ]
          )}
        '';
      };

    in
    {
      # TODO: Make profile management
      # TODO: Find a way to fetch mods off their Nexus page from within Nix code
      options.gaming.eldenRing = {
        modEngine3.enable = lib.mkEnableOption "ModEngine3" // {
          default = true;
        };
      };

      config = {
        environment.systemPackages = lib.mkIf config.gaming.eldenRing.modEngine3.enable [ me3 ];
        gaming.platforms.steam = {
          launchOptions.${id} = "${mergedOptions} %command%";
          protontricks.${id} = {
            grabfullscreen = true;
            graphics = "wayland";
          };
        };
      };
    };
}
