{ self, inputs, ... }:
{
  flake.nixosModules.core = { pkgs, config, lib, ... }:
  {
    imports = [
      self.nixosModules.nh
    ];
  };
}
