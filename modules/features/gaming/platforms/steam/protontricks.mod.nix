{
  lib,

  writeShellScriptBin,
  writeShellApplication,

  gawk,
  wine64Packages,
  winetricks,
  ...
}@pkgs:
let
  inherit (builtins)
    attrNames
    isNull
    length
    map
    mapAttrs
    ;

  inherit (lib)
    mapAttrsToList
    escapeShellArg
    concatLines
    filterAttrs
    getExe
    mkEnableOption
    mkOption
    types
    ;

  settings = import ./protontricks-settings.mod.nix pkgs;
  options = mapAttrs (name: { option, ... }: option) settings;
  checks = mapAttrs (name: { check, ... }: check) settings;

  stripNulls = filterAttrs (name: value: !isNull value);
in
{
  options = {
    enable = mkEnableOption "managing launch options for this app from nix" // {
      default = true;
    };

    settings = mkOption {
      type = with types; submodule { inherit options; };
      default = { };
      apply = stripNulls;
    };
  };

  buildScriptAttrs =
    { programs, ... }:
    let
      cfg = programs.steam;

      appPrefix = id: "${cfg.dirs.steamapps}/compatdata/${id}/pfx";

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
        OPTION_VALUE=${escapeShellArg value}
        ${checks.${option}}

        if (( $? )); then
          TRICKS+=(${escapeShellArg "${option}=${value}"})
        fi
      '';

      doAllChecks = tricks: concatLines (mapAttrsToList doCheck tricks);

      applyTricks = id: ''
        if (( ''${#TRICKS[@]} != 0 )); then
          target=$(grep -iF name "${cfg.dirs.steamapps}/appmanifest_${id}.acf" | cut -d '"' -f 4)
          echo "The following protontricks will be applied for ''${target:-"APPID #${id}"}:" >&2
          for trick in "''${TRICKS[@]}"; do
            echo " • $trick" >&2
          done

          protontricks ${id} -q settings "''${TRICKS[@]}" 2>&1 | awk '
            !/server-side synchronization/ { print "[protontricks] " $0; fflush() }
          '
          _status="''${PIPESTATUS[0]}"
        fi

        wineserver -k || true

        exit "$_status"
      '';

      writeTricksScript =
        id: tricks:
        writeShellApplication {
          name = "${name}:id";
          bashOptions = [ "pipefail" ];
          runtimeInputs = [
            gawk
            cfg.protontricks.package
            wine64Packages.minimal
            winetricks
          ];
          text = ''
            ${prepare id}
            ${doAllChecks tricks}
            ${applyTricks id}
          '';
        };

      allTricks = mapAttrs (id: { protontricks, ... }: protontricks.settings) cfg.app;
      enabledTricks = filterAttrs (id: _: cfg.apps.${id}.protontricks.enable) allTricks;

      enable = length (attrNames enabledTricks) > 0;

      name = "steam-apply-protontricks";

      subScripts = map writeTricksScript enabledTricks;

      mainScript = writeShellScriptBin name ''
        trap "EXIT_STATUS=1" ERR
        ${concatLines (map getExe subScripts)}
        exit "$EXIT_STATUS"
      '';

      exe = getExe mainScript;
    in
    {
      inherit
        name
        enable
        mainScript
        subScripts
        exe
        ;
      allScripts = mainScript ++ subScripts;
    };
}
