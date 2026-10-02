{ self, ... }:
{
  flake.nixosModules.core =
    {
      pkgs,
      lib,
      config,
      options,
      ...
    }:
    let
      cfg = config.core;
    in
    {
      imports = [ self.nixosModules.dev ];

      options =
        let
          inherit (lib) types;
        in
        {
          core.user = lib.mkOption {
            type = options.users.users.type.nestedTypes.elemType;
            description = ''
              Main user of the machine, as defined in `nixosConfiguration.<hostName>.users.users.<userName>`.
            '';
          };

          core.hostName = lib.mkOption {
            type = options.networking.hostName.type;
            description = ''
              Name of the machine

              Must be exactly identical to the nixosConfiguration.<name> used to build the machine's system.
            '';
          };

          core.flakePath = lib.mkOption {
            type = types.strMatching "^/([^/]/?)+";
            description = ''
              Absolute path to the directory containing this flake.
            '';
            default = "${cfg.user.home}/.config/nixos";
            apply = lib.removeSuffix "/";
          };
        };

      config = {
        boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

        networking.networkmanager.enable = true;
        networking.hostName = cfg.hostName;
        users.users.${cfg.user.name} = cfg.user;

        environment.systemPackages = with pkgs; [
          bat
          btop
          git
          lazygit
          neovim
        ];
      };
    };
}
