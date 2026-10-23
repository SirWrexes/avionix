{
  flake.nixosModules.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        findSingle
        isAttrs
        length
        mkIf
        mkOption
        types
        ;

      cfg = config.display;
    in
    {
      options.display =
        let
          monitor = types.submodule {
            options = {
              device = mkOption {
                type = types.str;
                description = "Device name (port)";
                example = "DP-1";
              };
              height = mkOption {
                type = types.ints.positive;
                description = "Monitor display height (pixels)";
                example = 1080;
              };
              width = mkOption {
                type = types.ints.positive;
                description = "Monitor display width (pixels)";
                example = 1920;
              };
              refreshRate = mkOption {
                type = types.ints.positive;
                description = "Monitor display refresh rate (hertz)";
                example = 60;
              };
              primary = mkOption {
                type = types.bool;
                description = "Set this monitor as your primary display";
                example = true;
                default = false;
              };
            };
          };
        in
        {
          monitors = mkOption {
            type = with types; listOf monitor;
            description = "List of monitor info";
            default = [ ];
          };

          primary = mkOption {
            type = with types; either str monitor;
            description = "Alias for display that is set with `primary = true`";
            readOnly = true;
            default = findSingle (
              m: m.primary
            ) "No primary monitor set" "Multiple primary monitors set" cfg.monitors;
          };

          monitorsConfigured = mkOption {
            type = with types; bool;
            default = length cfg.monitors > 0;
            readOnly = true;
            internal = true;
          };
        };

      config = mkIf cfg.monitorsConfigured {
        assertions = [
          {
            assertion = isAttrs cfg.primary;
            message = cfg.primary;
          }
        ];
      };
    };
}
