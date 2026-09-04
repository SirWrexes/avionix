{ self, inputs, ... }:
{
  flake.nixosModules.games = { ... }:
  {
    imports = [
        self.nixosModules.mangohud

        self.nixosModules.steam
        self.nixosModules.devilutionx
    ];
  };
}
