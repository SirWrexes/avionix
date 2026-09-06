{ self, inputs, ... }:
{
  flake.nixosModules.games = { ... }:
  {
    imports = [
        /* Tools */
        self.nixosModules.mangohud

        /* Platforms */
        self.nixosModules.steam
        self.nixosModules.battlenet

        /* Standlones: uncomment to install */
        # self.nixosModules.devilutionx
    ];
  };
}
