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
        isNull
        match
        ;

      inherit (lib)
        mkOption
        optional
        types
        ;

      userName = config.core.user.name;
      userHome = config.users.users.${userName}.home;

      cfg = config.programs.steam;

      submodules = {
        protontricks = import ./protontricks.mod.nix pkgs;
        launchOptions = import ./launch-options.mod.nix pkgs;
      };

      isSteamAppId = str: !isNull (match "^[[:digit:]]+$" str);
      ensureSteamAppIds =
        optType:
        types.addCheck optType (
          lib.foldlAttrs (
            acc: id: _opts:
            isSteamAppId id && acc
          ) true
        );

      steamAppModule = types.submodule {
        options = {
          launchOptions = submodules.launchOptions.options;
          protontricks = submodules.protontricks.options;
        };
      };
    in
    {
      options.programs.steam = {
        dirs = {
          steam = mkOption {
            type = with types; str;
            default = "${userHome}/.steam/steam";
          };
          steamapps = mkOption {
            type = with types; str;
            default = "${cfg.dirs.steam}/steamapps";
            readOnly = true;
          };
        };
        protontricks = {
          checks = mkOption {
            type = with types; attrsOf str;
            default = submodules.protontricks.checks;
            internal = true;
            readOnly = true;
          };
        };
        apps = mkOption {
          type = with types; ensureSteamAppIds (attrsOf steamAppModule);
          default = { };
          description = ''
            Set of options and configs for each of your Steam apps.
            For shortcuts to non-Steam apps, see `programs.steam.shortcuts` (arriving Soon™️).
          '';
        };
      };

      config =
        let
          launchOptions = submodules.launchOptions.buildScriptAttrs config;
          protontricks = submodules.protontricks.buildScriptAttrs config;
        in
        {
          environment.systemPackages =
            (with launchOptions; optional enable package) ++ (with protontricks; optional enable allScripts);

          system.userActivationScripts = {
            ${launchOptions.name} = {
              inherit (launchOptions) enable;
              text = ''
                ${launcOptionsScript.exe}
              '';
            };
            ${protontricks.name} = {
              inherit (protontricks) enable;
              text = ''
                ${protontricks.exe}
              '';
            };
          };
        };
    };
}
