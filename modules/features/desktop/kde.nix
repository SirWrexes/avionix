{ self, inputs, ... }:
{
  flake.nixosModules.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.desktop;

      kwriteconfig6 = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";
    in
    {
      options.desktop = {
        forceNumlockOnBoot = lib.mkEnableOption "NumLock on boot" // {
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        services = {
          desktopManager.plasma6.enable = true;
          displayManager.plasma-login-manager.enable = true;
        };

        # Force NumLock ON
        system.userActivationScripts.kdeNumlock = lib.mkIf cfg.forceNumlockOnBoot {
          text = ''
            ${kwriteconfig6} --file kcminputrc --group Keyboard --key NumLock 0
          '';
        };
      };
    };
}
