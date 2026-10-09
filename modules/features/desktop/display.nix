{
  flake.nixosModules.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.display;
    in
    {
      options.display =
        let
          inherit (lib) types;

          monitor = types.submodule {
            options = {
              device = lib.mkOption {
                type = types.str;
                description = "Device name (port)";
                example = "DP-1";
              };
              height = lib.mkOption {
                type = types.ints.positive;
                description = "Monitor display height (pixels)";
                example = 1080;
              };
              width = lib.mkOption {
                type = types.ints.positive;
                description = "Monitor display width (pixels)";
                example = 1920;
              };
              refreshRate = lib.mkOption {
                type = types.ints.positive;
                description = "Monitor display refresh rate (hertz)";
                example = 60;
              };
              primary = lib.mkOption {
                type = types.bool;
                description = "Set this monitor as your primary display";
                example = true;
                default = false;
              };
            };
          };
        in
        {
          monitors = lib.mkOption {
            type = with types; listOf monitor;
            description = "Attribute set of { <device> = <device info> }";
            default = [ ];
          };

          primary = lib.mkOption {
            type = with types; either str monitor;
            description = "Alias for display that is set with `primary = true`";
            readOnly = true;
            default = lib.findSingle (
              m: m.primary
            ) "No primary monitor set" "Multiple primary monitors set" cfg.monitors;
          };

          monitorsConfigured = lib.mkOption {
            type = with types; bool;
            readOnly = true;
            default = lib.length cfg.monitors > 0;
          };
        };

      config = lib.mkIf cfg.monitorsConfigured {
        assertions = [
          {
            assertion = builtins.isAttrs cfg.primary;
            message = cfg.primary;
          }
        ];
      };
    };
}
