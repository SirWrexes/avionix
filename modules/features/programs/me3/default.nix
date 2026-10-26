{ dirs, ... }:
{
  flake.nixosModules.programs =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        escapeShellArg
        flatten
        foldlAttrs
        mkEnableOption
        mkIf
        mkOption
        mkPackageOption
        optional
        types
        zipAttrs
        ;

      cfg = config.programs.me3;

      me3profile = types.submoduleWith {
        modules = [ (import ./me3profile.mod.nix) ];
        specialArgs = {
          inherit (pkgs) makeDesktopItem;
          inherit (pkgs.writers) writeTOML;
          inherit (dirs) icons;
        };
      };

    in
    {
      options.programs.me3 = {
        enable = mkEnableOption "ModEngine 3";

        package = mkPackageOption pkgs "me3" { };

        useSteamLaunchOptions = mkOption {
          type = with types; bool;
          default =
            let
              apps = config.programs.steam.apps or { };
              hasOptions = id: apps ? "${id}" -> (apps.${id}.launchOptions or { enable = false; }).enable;
            in
            (hasOptions "374320") # DS3
            || (hasOptions "814380") # Sekiro
            || (hasOptions "1245620") # ER
            || (hasOptions "1888160") # AC6
            || (hasOptions "2622380"); # ER: NR
          description = ''
            When enabled, desktop items that launch your modded games will also have the launch options from `programs.steam.apps.<id>.launchOptions`.
          '';
        };

        profiles = mkOption {
          type =
            with types;
            attrsWith {
              placeholder = "profile";
              elemType = me3profile;
            };
          default = { };
          description = ''
            Mod profile definitions.
          '';
        };
      };

      config =
        let
          enabledProfiles = foldlAttrs (
            acc: profile:
            { enable, result, ... }:
            optional enable { inherit (result) toml desktopItems; } ++ acc
          ) [ ] cfg.profiles;

          derivations = zipAttrs enabledProfiles;

          desktopItems = flatten derivations.desktopItems;

          profilesDir = pkgs.linkFarmFromDrvs "me3-profiles" derivations.toml;

          me3Wrapped = pkgs.symlinkJoin {
            name = "me3";
            paths = [ cfg.package ];
            nativeBuildInputs = with pkgs; [ makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/me3 \
                --add-flags "--profile-dir ${escapeShellArg profilesDir}"
            '';
          };
        in
        mkIf cfg.enable {
          environment.systemPackages = [ me3Wrapped ] ++ desktopItems;
        };
    };
}
