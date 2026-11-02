{
  self,
  inputs,
  hosts,
  description,
  ...
}:
{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        mkDefault
        mkIf
        mkOption
        types
        ;

      inherit (config.users) user;
    in
    {
      options.host = mkOption {
        type = with types; enum hosts;
      };

      config = {
        flake = {
          self = mkDefault self;
          name = mkDefault description;
          root = mkDefault "${user.home}/.config/nixos";
        };

        users.user = mkDefault self.users.wrexes;

        networking.hostName = mkDefault config.host;
        networking.networkmanager.enable = mkDefault true;

        # Use Xanmod kernel
        boot.kernelPackages = mkDefault pkgs.linuxPackages_xanmod_latest;

        # Make /tmp use RAM instead of disk
        boot.tmp = {
          useTmpfs = mkDefault true;
          tmpfsSize = mkDefault "50%";
          cleanOnBoot = mkDefault true;
        };

        #         security.sudo.package = mkDefault (pkgs.sudo.override { withInsults = true; });
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
          modules = [
            self.nixosModules.default
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
