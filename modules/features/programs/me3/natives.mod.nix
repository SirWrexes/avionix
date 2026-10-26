{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    enabled = mkOption {
      type = with types; bool;
      default = true;
      description = ''
        Should this native be loaded?
      '';
    };

    path = mkOption {
      type = with types; coercedTo package (pkg: "${pkg}/${pkg.nativeDllPath}") str;
      description = ''
        Path to the DLL. Alternatively, can also be a nix derivation packaging the mod.
        If providing a derivation, it must have a `passthru.nativeDllPath` attribute.
      '';
    };

    optional = mkOption {
      type = with types; bool;
      default = false;
      description = ''
        If this native fails to load and this value is false, treat it as a critical error.
      '';
    };

    load_before = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = ''
        Official description doesn't say much about it so IDK. My guess is they're package IDs.
      '';
    };

    load_after = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = ''
        Official description doesn't say much about it so IDK. My guess is they're package IDs.
      '';
    };

    load_early = mkOption {
      type = with types; bool;
      default = false;
    };
  };
}
