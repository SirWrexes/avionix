
{ self, inputs, ... }:
{
  flake.nixosModules.remote-touchpad = { config, pkgs, lib, ... }:
  {
    # TODO: Add some options and shit
    environment.systemPackages = with pkgs; [ remote-touchpad ];
  };
}
