{ self, ... }:
{
  flake.nixosModules.default.imports = with self.nixosModules; [
    age
    desktop
    dev
    flake
    fonts
    games
    hosts
    pkgsWithoutCuda
    programs
    scripts
    secrets
    services
    user
  ];
}
