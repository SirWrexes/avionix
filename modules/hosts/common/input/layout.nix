{
  flake.nixosModules.hosts =
    { lib, ... }:
    let
      inherit (lib) mapAttrs mkDefault;

      defaultAttrs = mapAttrs (name: value: mkDefault value);
    in
    {
      services.xserver.xkb = defaultAttrs {
        layout = "us";
        variant = "altgr-intl";
      };
    };
}
