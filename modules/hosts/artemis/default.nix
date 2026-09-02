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
        self.nixosModules.common

        self.nixosModules.artemis-hardware
        self.nixosModules.artemis-nvidia

        self.nixosModules.remote-touchpad

        # self.nixosModules.niri
        self.nixosModules.kde
        self.nixosModules.nh
        self.nixosModules.udiskie
        self.nixosModules.firefox
        self.nixosModules.steam
        self.nixosModules.discord
      ];

    # This machine's name
    networking.hostName = "artemis";
  };
} 
