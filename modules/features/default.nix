{ self, ... }:
{
  flake.nixosModules.default.imports = with self.nixosModules; [
    desktop
    dev
    flake
    fonts
    games
    programs
    scripts
    secrets
    services
    user
  ];
}
