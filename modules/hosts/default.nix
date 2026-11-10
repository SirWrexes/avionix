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
      options,
      ...
    }:
    let
      inherit (lib)
        mkDefault
        mkIf
        mkOption
        ;

      inherit (config.users) user;
    in
    {
      options.host = mkOption {
        type = options.networking.hostName.type;
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

        # Make /tmp use RAM instead of disk
        boot.tmp = {
          useTmpfs = mkDefault true;
          tmpfsSize = mkDefault "50%";
          cleanOnBoot = mkDefault true;
        };

        # If /tmp is on RAM, move nix's temp dir for shells and builds to somewhere else on disk.
        # This is because limiting TMPDIR can cause large builds to fail if the tmpfs is full, e.g. after several days
        # of uptime.
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
              age = mkDefault "3d";
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

      allSystems = map systemFor hosts;
    in
    listToAttrs allSystems;
}
