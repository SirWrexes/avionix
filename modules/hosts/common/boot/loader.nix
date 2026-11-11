{
  flake.nixosModules.hosts =
    { lib, ... }:
    let
      inherit (lib) mkDefault;
    in
    {
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot = {
        enable = true;
        bootCounting.enable = mkDefault true;
      };
    };
}
