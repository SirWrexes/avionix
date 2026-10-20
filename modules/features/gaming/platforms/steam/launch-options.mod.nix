{
  name,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.launchOptions;
in
{
  options.launchOptions = {
    enable = mkEnableOption "managing launch options for app ${name} from nix" // {
      default = !isNull cfg.text;
    };

    text = mkOption {
      type = with types; nullOr str;
      description = "Steam app ${name}'s launch options";
      default = null;
    };
  };
}
