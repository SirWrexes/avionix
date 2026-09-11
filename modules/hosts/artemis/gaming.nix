{ self, inputs, ... }:
{
  flake.nixosModules.artemis.gaming = {
    platforms = {
      steam.enable = true;
      battlenet.enable = true;
    };

    tools.mangohud.enable = true;
  };
}
