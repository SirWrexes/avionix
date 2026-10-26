{ name, lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    id = mkOption {
      type = with types; str;
      default = name;
      description = ''
        The unique identifier for this package. Defaults to its ${name}.
      '';
    };

    enabled = mkOption {
      type = with types; bool;
      default = true;
      description = ''
        Enable this package?
      '';
    };

    path = mkOption {
      type = with types; coercedTo package toString str;
      description = ''
        Path to the root of the asset replacement mod. Alternatively, can also be a nix derivation packaging the mod.
      '';
    };

    load_after = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = ''
        A list of package IDs that this package should load after.
      '';
    };

    load_before = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = ''
        A list of packages that this package should load before.
      '';
    };

    result = mkOption {
      type = with types; json;
      internal = true;
    };
  };
}
