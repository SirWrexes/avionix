{
  flake.nixosModules.programs =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (builtins)
        attrNames
        concatStringsSep
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
        mkOption
        optional
        optionalString
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
            addCheck (attrsWith {
              placeholder = "id";
              elemType = steamAppModule;
            }) (attrs: map isSteamAppId (attrNames attrs));
          default = { };
          description = ''
            Set of options and configs for each of your Steam apps.
            For shortcuts to non-Steam apps, see `programs.steam.shortcuts` (arriving Soon™️).
          '';
        };
      };

      # TODO: Check if I can reduce the number of passes over cfg.apps with lib.mapAttrsOfSubmodule
      config = mkIf cfg.enable {
        assertions = [
          (
            let
              invalidNames = foldlAttrs (
                acc: id:
                { protontricks, launchOptions, ... }:
                acc ++ (optional ((protontricks.enable || launchOptions.enable) && (!isSteamAppId id)) id)
              ) [ ] cfg.apps;
              invalidNameCount = length invalidNames;
            in
            {
              assertion = invalidNameCount == 0;
              message = ''
                Invalid Steam app ID${optionalString (invalidNameCount > 1) "s"}:
                    ${concatStringsSep "\n    " invalidNames}
                  Please edit the corresponding attribute names in `programs.steam.apps`.
              '';
            }
          )
        ];

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
            enable = cfg.protontricks.enable && (length scripts > 0);
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
