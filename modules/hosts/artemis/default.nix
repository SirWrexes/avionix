{ self, inputs, ... }:
{
  flake.nixosConfigurations.artemis = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.artemis-config
    ];
  };

  flake.nixosModules.artemis-config = { config, pkgs, ... }:
  {
    imports =
      [ 
        self.nixosModules.core
        self.nixosModules.desktop
        self.nixosModules.games
        self.nixosModules.common

        self.nixosModules.artemis-hardware
        self.nixosModules.artemis-nvidia
      ];

    # This machine's name
    networking.hostName = "artemis";
  };
}
