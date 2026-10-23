{
  flake.nixosModules.hosts =
    { lib, ... }:
    let
      inherit (lib) mapAttrs mkDefault;

      defaultAttrs = mapAttrs (name: value: mkDefault value);
    in
    {
      time.timeZone = mkDefault "Europe/Paris";

      i18n.defaultLocale = mkDefault "en_GB.UTF-8";
      i18n.extraLocaleSettings = defaultAttrs {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };
    };
}
