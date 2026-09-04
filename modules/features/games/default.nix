{ self, inputs, ... }:
{
  flake.nixosModules.games = { ... }:
  {
    imports = [
        /* Tools */
        self.nixosModules.mangohud

        /* Platforms */
        self.nixosModules.steam

        /* Standlones */
        self.nixosModules.devilutionx
    ];
  };
}
