{ self, inputs, ... }:
{
  flake.nixosModules.desktop = { pkgs, lib, config, ... }:
  {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
    };

    # Force NumLock ON
    system.userActivationScripts.kdeNumlock = {
      text = ''
        ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kcminputrc --group Keyboard --key NumLock 0
      '';
    };
  };
}
