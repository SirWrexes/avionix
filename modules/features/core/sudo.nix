{ self, inputs, ... }:
{
  flake.nixosModules.sudo = { pkgs, config, lib, ... }:
  {
    security.sudo.package = pkgs.sudo.override { withInsults = true; };
  };
}
