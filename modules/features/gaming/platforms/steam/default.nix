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
        attrNames
        isNull
        length
        mapAttrs
        match
        ;

      inherit (lib)
        filterAttrs
        foldlAttrs
        getExe
        makeBinPath
        mkIf
        mkAssert
        mkOption
        optional
        readFile
        types
        ;

      userName = config.core.user.name;
      userHome = config.users.users.${userName}.home;

      cfg = config.programs.steam;

      steamAppIdRegex = "^[1-9][[:digit:]]+$";
      isSteamAppId = str: !isNull (match steamAppIdRegex str);

      steamAppModule = types.submoduleWith {
        modules = [
          (import ./launch-options.mod.nix)
          (import ./protontricks.mod.nix)
          ({ config, ... }: {
            config =
              with config._module.args;
              mkAssert (isSteamAppId name)
                ''Invalid Steam app ID: ${name}. Must match \033[1m${steamAppIdRegex}\033[0m''
                { };
          })
        ];
        specialArgs = {
          inherit pkgs;
          inherit (config.programs) steam;
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
        apps = mkOption {
          type =
            with types;
            attrsWith {
              placeholder = "id";
              elemType = steamAppModule;
            };
          default = { };
          description = ''
            Set of options and configs for each of your Steam apps.
            For shortcuts to non-Steam apps, see `programs.steam.shortcuts` (arriving Soon™️).
          '';
        };
      };

      config = mkIf cfg.enable {
        #         assertions = [
        #           {
        #             assertion = foldlAttrs (
        #               acc: id: _:
        #               isSteamAppId id && acc
        #             ) true cfg.apps;
        #             message = ''Invalid Steam app ID. Must match '\033[1m${steamAppIdRegex}\033[0m'.'';
        #           }
        #         ];

        systemd.user.services.steam-apply-launch-options =
          let
            allOptions = mapAttrs (id: { launchOptions, ... }: launchOptions.text) cfg.apps;
            enabledOptions = filterAttrs (id: text: cfg.apps.${id}.launchOptions.enable) allOptions;
            enable = length (attrNames enabledOptions) > 0;

            json = pkgs.writers.writeJSON "launch-options.json" enabledOptions;
            script = pkgs.writers.writePython3Bin "steam-apply-launch-options" {
              libraries = with pkgs.python3Packages; [ vdf ];
              flakeIgnore = [ "E501" ];
              makeWrapperArgs = [
                "--prefix"
                "PATH"
                ":"
                (makeBinPath [
                  cfg.package
                  config.systemd.package
                  pkgs.procps
                ])
              ];
            } (readFile ./steamopts.py);
          in
          mkIf enable {
            serviceConfig = {
              ExecStart = getExe script;
              Type = "oneshot";
            };
            reloadTriggers = [
              json
              script
            ];
            environment = {
              STEAMOPTS_STEAM_DIR = cfg.dirs.steam;
              STEAMOPTS_JSON = json;
            };
          };

        systemd.user.services.steam-apply-protontricks =
          let
            scripts = foldlAttrs (
              acc: id: { protontricks, ... }: acc ++ (optional protontricks.enable protontricks.script)
            ) [ ] cfg.apps;
            enable = length scripts > 0;
          in
          mkIf enable {
            serviceConfig = {
              ExecStart = map (script: "-${getExe script}") scripts;
              Type = "oneshot";
            };
            reloadTriggers = scripts;
            environment = {
              WINETRICKS_SUPER_QUIET = "1";
              WINEDEBUG = "-fixme,-warn,-trace,-wineusb";
              PROTON_NO_FSYNC = "1";
              PROTON_NO_ESYNC = "1";
              WINEFSYNC = "0";
              WINEESYNC = "0";
            };
          };
      };
    };
}
