{ self, inputs, ... }:
{
  flake.nixosModules.desktop = { config, pkgs, lib, ... }:
  {
    imports = [
      self.nixosModules.discord
      self.nixosModules.firefox
      self.nixosModules.fonts
      self.nixosModules.kde
    ];

    hardware.openrazer = {
      enable = true;
      users = [ "wrexes" ];
    };

    services.input-remapper.enable = true;
  };
}
