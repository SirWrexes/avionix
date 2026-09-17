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

  flake.nixosModules.artemis =
    { ... }:
    {
      core.hostName = "artemis";
      core.user = self.users.wrexes;
    };
}
