{
  flake.nixosModules.hosts = { config, ... }: {
    programs.git = {
      enable = true;
      lfs.enable = true;
    };
  };
}
