{
  name,
  lib,
  config,
  icons,
  makeDesktopItem,
  writeTOML,
  ...
}:
let
  inherit (lib)
    attrValues
    escapeShellArg
    mapAttrs
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    optionals
    replaceStrings
    types
    ;

  games = {
    enum = [
      "darksouls3"
      "sekiro"
      "eldenring"
      "armoredcore6"
      "nightreign"
    ];
    "darksouls3" = "Dark Souls III";
    "sekiro" = "Sekiro: Shadows Die Twice";
    "eldenring" = "Elden Ring";
    "armoredcore6" = "Armored Core VI";
    "nightreign" = "Elden Ring: Nightrein";
  };

  modules = {
    natives = types.submodule (import ./natives.mod.nix);
    packages = types.submodule (import ./packages.mod.nix);
  };
in
{
  options = {
    enable = mkEnableOption "ModEngine 3 profile: ${name}" // {
      default = true;
    };

    makeDesktopItems = mkEnableOption "dekstop item for ${name}" // {
      default = true;
    };

    settings = {
      supports = mkOption {
        type = with types; listOf (enum games.enum);
        default = [ ];
        description = ''
          The games that this profile supports.
        '';
      };

      start_online = mkOption {
        type = with types; bool;
        default = false;
        description = ''
          Starts the game with multiplayer server connectivity enabled.
        '';
      };

      disable_arxan = mkOption {
        type = with types; bool;
        default = false;
        description = ''
          Try to neutralize Arxan GuardIT code protection to improve mod stability.
        '';
      };

      mem_patch = mkOption {
        type = with types; bool;
        default = false;
        description = ''
          Patch memory limits for supported games to improve mod stability.
        '';
      };

      mem_patch_heap_size = mkOption {
        type = with types; ints.between 0 4294967295;
        default = 0;
        description = ''
          Override how many megabytes of memory the supported game should allocate (with `mem_patch = true`). Minimum: `0`.
        '';
      };

      natives = mkOption {
        type = with types; attrsOf modules.natives;
        default = { };
        description = ''
          Each attribute defines a native DLL mod to load.
        '';
        apply = attrValues;
      };

      packages = mkOption {
        type = with types; attrsOf modules.packages;
        default = { };
        description = ''
          Each attribute defines a package of asset overrides.
        '';
        apply = attrValues;
      };
    };

    result = {
      toml = mkOption {
        type = with types; package;
        internal = true;
      };
      desktopItems = mkOption {
        type = with types; listOf package;
        internal = true;
      };
    };
  };

  config =
    with config;
    mkIf enable {
      result.toml = writeTOML "${name}.me3" settings;

      result.desktopItems = optionals makeDesktopItems (
        let
          snakeName = replaceStrings [ " " ] [ "_" ] name;
        in
        map (
          game:
          makeDesktopItem {
            name = "me3-${game}-${snakeName}";
            desktopName = "${games.${game}} (${name})";
            comment = "Play ${games.${game}} with mod profile ${name} enabled";
            icon = "${icons}/${game}.ico";
            categories = [ "Game" ];
            exec = ''me3 launch --game ${game} --profile "${config.result.toml}"'';
          }
        ) settings.supports
      );
    };
}
