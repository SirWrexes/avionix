{ self, inputs, ... }:
{
  flake.nixosModules.core = { pkgs, config, lib, ... }:
  {
    security.sudo.package = pkgs.sudo.override { withInsults = true; };
  };
}
