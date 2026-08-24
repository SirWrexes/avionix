{ self, inputs, config, ... }:
{
  flake.nixosModules.kde = { pkgs, lib, ... }:
  {
    services = {
      desktopManager.plasma6.enable = true;
      displaymanager.plasma-login-manager.enable = true;
    };
  };
}
