{
  flake.nixosModules.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.gaming.platforms.steam;

      module = import ./_tricks.nix pkgs;
      options = builtins.mapAttrs (name: { option, ... }: option) module;
      checks = builtins.mapAttrs (name: { check, ... }: check) module;
    in
    {
      options.gaming.platforms.steam =
        let
          inherit (lib) types mkOption;

          stripNulls = lib.filterAttrs (name: value: !builtins.isNull value);
        in
        {
          protontricks = mkOption {
            type =
              with types;
              attrsOf (submodule {
                inherit options;
              });
            default = { };
            apply = builtins.mapAttrs (id: stripNulls);
          };
        };

      config =
        let
          appPrefix = id: "${cfg.steamAppsDir}/compatdata/${id}/pfx";

          prepare = id: ''
            WINEPREFIX="${appPrefix id}"

            if [ ! -d "$WINEPREFIX" ]; then
              printf "Wine prefix not found for Steam app %s. Skipping." "${id}"
              exit 0
            fi

            export WINETRICKS_SUPER_QUIET=1
            export WINEDEBUG="-fixme,-warn,-trace,-wineusb"
            export PROTON_NO_FSYNC=1
            export PROTON_NO_ESYNC=1
            export WINEFSYNC=0
            export WINEESYNC=0

            HKCU="$WINEPREFIX/user.reg"
            HKLM="$WINEPREFIX/system.reg"

            declare -a TRICKS

            wineserver -k
          '';

          doCheck = option: value: ''
            OPTION_VALUE=${lib.escapeShellArg value}
            ${checks.${option}}

            if (( $? )); then
              TRICKS+=(${lib.escapeShellArg "${option}=${value}"})
            fi
          '';

          doAllChecks = tricks: lib.concatLines (lib.mapAttrsToList doCheck tricks);

          applyTricks = id: ''
            if (( ''${#TRICKS[@]} != 0 )); then
              echo "The following protontricks will be applied for $(
                grep -iF name "${cfg.steamAppsDir}/appmanifest_${id}.acf" | cut -d '"' -f 4
              ):"
              for trick in "''${TRICKS[@]}"; do
                echo " • $trick"
              done

              protontricks ${id} -q settings "''${TRICKS[@]}" 2>&1 | awk '
                !/server-side synchronization/ { print "[protontricks] " $0; fflush() }
              '
              _status="''${PIPESTATUS[0]}"
            fi

            wineserver -k || true

            exit "$_status"
          '';

          makeTricksScript = id: tricks: ''
            ${prepare id}
            ${doAllChecks tricks}
            ${applyTricks id}
          '';
        in
        lib.mkIf config.programs.steam.protontricks.enable {
          system.userActivationScripts = lib.mapAttrs' (
            id: tricks:
            let
              name = "steam-apply-protontricks-${id}";
              script = pkgs.writeShellApplication {
                inherit name;
                text = makeTricksScript id tricks;
                bashOptions = [ "pipefail" ];
                runtimeInputs = with pkgs; [
                  gawk
                  protontricks
                  wine64Packages.minimal
                  winetricks
                ];
                excludeShellChecks = [
                  "SC2034"
                  "SC2181"
                ];
              };
            in
            {
              inherit name;
              value.text = ''
                ${lib.getExe script}
              '';
            }
          ) cfg.protontricks;
        };
    };
}
