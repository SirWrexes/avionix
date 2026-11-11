{
  self,
  inputs,
  description,
  ...
}:
{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      options,
      ...
    }:
    let
      inherit (lib) mkDefault mkOption;
      inherit (config.users) user;
    in
    {
      options.host = mkOption {
        inherit (options.networking.hostName) type;
      };

      config = {
        flake = {
          host = config.host;
          self = self;
          name = description;
          root = mkDefault "${user.home}/.config/nixos";
        };

        users.user = mkDefault self.users.wrexes;

        networking.hostName = mkDefault config.host;
        networking.networkmanager.enable = mkDefault true;

        # Use Xanmod kernel
        boot.kernelPackages = mkDefault pkgs.linuxKernel.packages.linux_xanmod;

        # Le funny disrespect when I input le wrong password on accident
        security.sudo.package = mkDefault (pkgs.sudo.override { withInsults = true; });
      };
    };

  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs.lib)
        map
        mergeAttrsList
        nixosSystem
        ;

      systemFor = host: {
        "${host}" = nixosSystem {
          modules = [
            inputs.agenix.nixosModules.default
            self.nixosModules.default
            self.nixosModules.hosts
            self.nixosModules.age
            self.nixosModules.pkgsNoCuda
            {
              inherit host;
              imports = [ self.hardwareConfigs.${host} ];
            }
          ];
        };
      };

      allSystems = map systemFor [ "artemis" ];
    in
    mergeAttrsList allSystems;
}
