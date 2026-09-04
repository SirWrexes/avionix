{ self, inputs, config, ... }:
{
  flake.nixosModules.kde = { pkgs, lib, ... }:
  {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
    };
  };
}
