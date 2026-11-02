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

        # If /tmp is on RAM, move nix's temp dir for shells and builds to somewhere else on disk
        environment.sessionVariables.TMPDIR = mkIf config.boot.tmp.useTmpfs (mkDefault "/var/tmp/nix");
        systemd.tmpfiles.settings."99-nix-tmpdir" =
          let
            TMPDIR = config.environment.sessionVariables.TMPDIR or "";
          in
          mkIf (TMPDIR != "") ({
            ${TMPDIR}.d = {
              group = "users";
              mode = "0755";
              user = "${user.name}";
              age = mkDefault "7d"; # Clean orphaned contents older than 7 days
            };
          });

        # Le funny disrespect when I input le wrong password on accident
        security.sudo.package = mkDefault (pkgs.sudo.override { withInsults = true; });
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
