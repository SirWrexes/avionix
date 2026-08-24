{ self, inputs, ... }:
{
  flake.nixosModules.udiskie = { config, pkgs, lib, ... }:
  {
    services.udisks2.enable = true;
    environment.systemPackages = [ pkgs.udiskie ];
  };
}
