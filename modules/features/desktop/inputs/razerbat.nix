{
  self,
  inputs,
  packagesDir,
  ...
}:
{
  flake.nixosModules.razerbat =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.services.razerbat;
    in
    {
      options.services.razerbat = {
        enable = lib.mkEnableOption "Razer battery indicator";

        devices = lib.mkOption {
          type = with lib.types; either str (listOf str);
          description = ''
            Device(s) to enable the tray for.

            If left empty, razerbat will be installed but no autostart service will be created.
          '';
          default = [ ];
          apply = dev: if lib.isString dev then [ dev ] else dev;
        };

        quitOnDisconnect = lib.mkOption {
          type = with lib.types; either str (listOf str);
          description = ''
            Device(s) to enable quitting on disconnect for.
          '';
          default = [ ];
          apply = dev: if lib.isString dev then [ dev ] else dev;
        };

        package = lib.mkPackageOption self.packages.${pkgs.stdenv.hostPlatform.system} "razerbat" { };
      };

      config =
        let
          kebabify = str: lib.toLower (builtins.replaceStrings [ " " ] [ "-" ] str);

          shouldQuitOnDisconnect = device: builtins.elem device cfg.quitOnDisconnect;

          toUnit =
            device:
            let
              onDisconnectFlag = lib.optionalString (shouldQuitOnDisconnect device) " --quit-on-disconnect";
            in
            {
              "razerbat-${kebabify device}" = {
                enable = true;
                after = [ "graphical-session.target" ];
                wantedBy = [ "graphical-sesstion.target" ];
                description = "Razer battery indicator for ${device}";
                serviceConfig = {
                  type = "simple";
                  ExecStart = ''${lib.getExe cfg.package} "${device}"${onDisconnectFlag}'';
                };
              };
            };

          toServiceAttrs = devices: lib.mergeAttrsList (builtins.map toUnit devices);
        in
        lib.mkIf cfg.enable {
          assertions = [
            {
              assetion = ((lib.length config.hardware.openrazer.users) > 0) || ((lib.length cfg.users) > 0);
              message = ''
                OpenRazer requires its user(s) to be assigned to the `openrazer` group to interact with the daemon.
                Either provide user(s) with `hardware.openrazer.users` or `services.razerbat.users`.
              '';
            }
          ];

          hardware.openrazer = {
            enable = true;
            users = lib.mkIf ((lib.length cfg.users) > 0) cfg.users;
          };

          environment.systemPackages = [ cfg.package ];

          systemd.user.services = toServiceAttrs cfg.devices;
        };
    };

  perSystem =
    {
      self',
      lib,
      pkgs,
      ...
    }:
    {
      packages.razerbat = pkgs.callPackage "${packagesDir}/razerbat.nix" { };
    };
}
