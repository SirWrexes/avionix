{ self, inputs, ... }:
{
  flake.nixosModules.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        discord
        vesktop # TODO: make a wrapper with plugin configs
      ];
    };
}
