{
  self,
  inputs,
  hosts,
  ...
}:
{
  flake.nixosModules.hosts =
    { lib, config, ... }:
    let
      inherit (lib) mkDefault mkOption types;
    in
    {
      options.host = mkOption {
        type = with types; enum hosts;
      };

      config = {
        networking.hostName = mkDefault config.host;
      };
    };

  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs.lib)
        map
        listToAttrs
        nixosSystem
        ;

      systemFor = host: {
        name = host;
        value = nixosSystem {
          modules = with self.nixosModules; [
            inputs.agenix.nixosModules.default

            core
            desktop
            dev
            games
            pkgsWithoutCuda
            programs
            secrets
            services

            self.nixosModules.hosts

            {
              inherit host;
              imports = [ self.hardwareConfigs.${host} ];
            }
          ];
        };
      };

      allSystems = map systemFor hosts;
    in
    listToAttrs allSystems;
}
