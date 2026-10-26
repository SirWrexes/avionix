{
  flake.nixosModules.hosts =
    { pkgs, lib, ... }:
    let
      inherit (lib) mkDefault;
    in
    {
      flake.kateproject.enable = mkDefault true;

      services = {
        desktopManager.plasma6.enable = mkDefault true;
        displayManager.plasma-login-manager.enable = mkDefault true;
      };
    };
}
