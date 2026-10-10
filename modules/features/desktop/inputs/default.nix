{ self, ... }:
{
  flake.nixosModules.desktop.imports = with self.nixosModules; [
    razerbat
    inputRemapper
  ];
}
