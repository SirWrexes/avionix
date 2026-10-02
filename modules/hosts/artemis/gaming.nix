{
  flake.nixosModules.artemis.gaming = {
    platforms = {
      steam.enable = true;
      battlenet.enable = true;
    };

    tools.mangohud.enable = true;

    games.devilutionx = {
      # enable = true;
      gameFiles = [
        # TODO use secrets here
      ];
    };
  };
}
