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
      options =
        let
          inherit (lib) types;
        in
        {
          core.user = lib.mkOption {
            type = with types; nullOr options.users.users.type.nestedTypes.elemType;
            description = ''
              Main user of the machine, as defined in `nixosConfiguration.<hostName>.users.users.<userName>`.
            '';
          };

          core.flakePath = lib.mkOption {
            type = types.strMatching "^/([^/]+/?)+";
            description = ''
              Absolute path to the directory containing this flake.
            '';
            default = "${cfg.user.home}/.config/nixos";
            apply = lib.removeSuffix "/";
          };

          core.system = lib.mkOption {
            type = types.str;
            description = ''
              Alias for for `pkgs.stdenv.hostPlatform.system`.
            '';
            readOnly = true;
            default = pkgs.stdenv.hostPlatform.system;
          };
        };

      config = {
        assertions = [
          {
            assertion = !builtins.isNull cfg.user;
            message = "You must set a main user using `core.user`";
          }
        ];

        boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

        networking.networkmanager.enable = true;
        users.users.${cfg.user.name} = cfg.user;

        boot.tmp = {
          useTmpfs = true;
          tmpfsSize = "50%";
          cleanOnBoot = true;
        };

        environment.systemPackages = with pkgs; [
          fd
          ripgrep
          bat
          btop
          lazygit
          neovim
          wl-clipboard
        ];

        programs.git = {
          enable = true;
          lfs.enable = true;
        };
      };
    };
}
