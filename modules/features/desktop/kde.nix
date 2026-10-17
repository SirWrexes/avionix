{ self, ... }:
{
  flake.nixosModules.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (config.core) flakePath hostName system;

      cfg = config.desktop;

      kwriteconfig6 = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";
    in
    {
      options.desktop = {
        forceNumlockOnBoot = lib.mkEnableOption "NumLock on boot" // {
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        services = {
          desktopManager.plasma6.enable = true;
          displayManager.plasma-login-manager.enable = true;
        };

        # Force NumLock ON
        system.userActivationScripts.kdeNumlock = lib.mkIf cfg.forceNumlockOnBoot {
          text = ''
            ${kwriteconfig6} --file kcminputrc --group Keyboard --key NumLock 0
          '';
        };

        # Create a .kateproject inside the flake
        systemd.user.tmpfiles.rules =
          let
            nixTargets = [
              {
                name = "Update flake inputs";
                build_cmd = ''nix flake update --flake "${flakePath}"'';
              }
            ];

            nhTargets =
              builtins.map
                ({ name, build_cmd }: {
                  inherit name;
                  build_cmd = "NH_NOM=off ${lib.getExe config.programs.nh.package} ${build_cmd}";
                })
                [
                  {
                    name = "NixOS Build";
                    build_cmd = ''os build -o "${flakePath}/build/${hostName}"'';
                  }
                  {
                    name = "NixOS Test";
                    build_cmd = "os test";
                  }
                  {
                    name = "NixOS Switch";
                    build_cmd = "os switch";
                  }
                ];

            packageTargets = builtins.map (name: {
              name = "Build package: ${name}";
              build_cmd = "nix build ${flakePath}#packages.${system}.${name} -o ${flakePath}/build/packages/${system}/${name}";
            }) (builtins.attrNames self.packages.${system});

            finalTargets = nixTargets ++ nhTargets ++ packageTargets;

            kateproject = pkgs.writeText "kateproject-generated" (
              builtins.toJSON {
                name = "Avionix — System config from outer space";
                files = [ { git = true; } ];
                build = {
                  directory = builtins.toString flakePath;
                  targets = finalTargets;
                };
                lspclient.servers.nix = {
                  highlightingModeRegex = "^Nix$";
                  url = "https://github.com/oxalica/nil";
                  command = [ (lib.getExe config.dev.nix.lsp) ];
                  settings.nil.nix.flake = {
                    autoArchive = true;
                    autoEvalInputs = true;
                  };
                };
              }
            );
          in
          [
            "r  ${flakePath}/.kateproject.build"
            "L+ ${flakePath}/.kateproject - - - - ${kateproject}"
          ];
      };
    };
}
