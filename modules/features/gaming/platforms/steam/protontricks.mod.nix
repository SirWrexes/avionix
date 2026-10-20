{
  name,
  pkgs,
  lib,
  config,
  steam,
  ...
}:
let
  inherit (builtins)
    attrNames
    isNull
    length
    mapAttrs
    ;

  inherit (lib)
    concatLines
    escapeShellArg
    filterAttrs
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.protontricks;

  definitions = import ./protontricks-settings.mod.nix pkgs;
  options = mapAttrs (name: { option, ... }: option) definitions;
  checks = mapAttrs (name: { check, ... }: check) definitions;

  stripNulls = filterAttrs (name: value: !isNull value);

  prepare = id: ''
    WINEPREFIX="${steam.dirs.steamapps}/compatdata/${id}/pfx"

    if [ ! -d "$WINEPREFIX" ]; then
      printf "Wine prefix not found for Steam app %s. Skipping." "${id}"
      exit 0
    fi

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
      target=$(grep -iF name "${steam.dirs.steamapps}/appmanifest_${id}.acf" | cut -d '"' -f 4)
      echo "The following protontricks will be applied for ''${target:-"APPID #${id}"}:"
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

  writeTricksScript =
    id: tricks:
    pkgs.writeShellApplication {
      name = "steam-apply-protontricks-${name}";
      bashOptions = [ "pipefail" ];
      text = ''
        ${prepare id}
        ${doAllChecks tricks}
        ${applyTricks id}
      '';
      runtimeInputs =
        (with pkgs; [
          gawk
          wine64Packages.minimal
          winetricks
        ])
        ++ (with steam; [
          protontricks.package
        ]);
      excludeShellChecks = [
        "SC2034"
        "SC2181"
      ];
    };
in
{
  options.protontricks = {
    enable = mkEnableOption "managing launch options for this app ${name} from nix" // {
      default = (length (attrNames cfg.settings) > 0);
    };

    settings = mkOption {
      type = with types; submodule { inherit options; };
      default = { };
      apply = stripNulls;
    };

    script = mkOption {
      type = with types; nullOr package;
      internal = true;
      default = null;
    };
  };

  config =
    with cfg;
    mkIf enable {
      protontricks.script = writeTricksScript name settings;
    };
}
