{ self, inputs, ... }:
{
  flake.nixosConfigurations.artemis = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.core
      self.nixosModules.desktop
      self.nixosModules.gaming
      self.nixosModules.artemis
    ];
  };

  flake.nixosModules.artemis = { config, pkgs, ... }:
  {
    networking.hostName = "artemis";

    gaming.platforms = {
      steam.enable = true;
      battlenet.enable = true;
    };

    gaming.tools.mangohud.enable = true;
  };
}
