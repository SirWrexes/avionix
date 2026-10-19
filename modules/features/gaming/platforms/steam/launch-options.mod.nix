{
  lib,

  python314Packages,
  python3Packages,

  procps,
  ...
}:
let
  inherit (builtins)
    attrNames
    length
    mapAttrs
    toJSON
    ;

  inherit (lib)
    filterAttrs
    getExe
    mkEnableOption
    mkOption
    types
    ;
in
{
  options = {
    enable = mkEnableOption "managing launch options for this app from nix" // {
      default = true;
    };

    text = mkOption {
      type = with types; str;
      description = "Your app's launch command line";
    };
  };

  buildScriptAttrs =
    { systemd, programs, ... }:
    let
      cfg = programs.steam;

      allOpts = mapAttrs (id: { launchOptions, ... }: launchOptions.text) cfg.apps;
      enabledOpts = filterAttrs (id: _: cfg.apps.${id}.launchOptions.enable) allOpts;

      enable = length (attrNames enabledOpts) > 0;

      json = toJSON "launch-options.json" enabledOpts;

      pname = "steam-apply-launch-options";

      package = python3Packages.buildPythonApplication (finalAttrs: {
        inherit pname;

        src = ./steamopts.py;
        dontUnpack = true;

        libraries = with python314Packages; [ vdf ];
        runtimeInputs = [
          cfg.package
          systemd.package
          procps
        ];

        patchPhase = ''
          cp $src steamopts.py
          substituteInPlace steamopts.py \
            --replace-fail "@RAW_STEAM_PATH@" ${lib.escapeShellArg cfg.dirs.steam} \
            --replace-fail "@LAUNCH_OPTIONS_JSON@" ${lib.escapeShellArg json}
        '';
      });

      exe = getExe package;
    in
    {
      inherit enable package exe;
      name = pname;
    };
}
