{
  self,
  dirs,
  ...
}:
{
  flake.nixosModules.services =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        elem
        getExe
        isString
        length
        map
        mergeAttrsList
        mkEnableOption
        mkIf
        mkOption
        mkPackageOption
        optionalString
        replaceStrings
        toLower
        types
        ;

      inherit (pkgs.stdenv.hostPlatform) system;

      cfg = config.services.razerbat;
    in
    {
      options.services.razerbat = {
        enable = mkEnableOption "Razer battery indicator";

        devices = mkOption {
          type = with types; either str (listOf str);
          description = ''
            Device(s) to enable the tray for.
            If left empty, razerbat will be installed but no autostart service will be created.
          '';
          example = [ "Naga V2 HyperSpeed" ];
          default = [ ];
          apply = dev: if isString dev then [ dev ] else dev;
        };

        quitOnDisconnect = mkOption {
          type = with types; either str (listOf str);
          description = ''
            Device(s) to enable quitting on disconnect for.
          '';
          example = [ "Naga V2 HyperSpeed" ];
          default = [ ];
          apply = dev: if isString dev then [ dev ] else dev;
        };

        package = mkPackageOption self.packages.${system} "razerbat" { };
      };

      config =
        let
          inherit (config.hardware) openrazer;

          kebabify = str: toLower (replaceStrings [ " " ] [ "-" ] str);

          shouldQuitOnDisconnect = device: elem device cfg.quitOnDisconnect;

          toUnit =
            device:
            let
              onDisconnectFlag = optionalString (shouldQuitOnDisconnect device) "--quit-on-disconnect";
            in
            {
              "razerbat-${kebabify device}" = {
                enable = true;
                after = [ "graphical-session.target" ];
                wantedBy = [ "graphical-session.target" ];
                description = "Razer battery indicator for ${device}";
                serviceConfig = {
                  Type = "simple";
                  ExecStart = ''${getExe cfg.package} "${device}" ${onDisconnectFlag}'';
                };
                restartTriggers = [ cfg.package ];
              };
            };

          toServiceAttrs = devices: mergeAttrsList (map toUnit devices);
        in
        mkIf cfg.enable {
          assertions = [
            {
              assertion = openrazer.enable;
              message = ''
                Razerbat depends on OpenRazer.
                Enable it with `hardware.openrazer.enable = true`.
              '';
            }
            {
              assertion = length openrazer.users > 0;
              message = ''
                OpenRazer and Razerbat require users to be given the `openrazer` group.
                Set them with `hardware.openrazer.users`.
              '';
            }
          ];
          environment.systemPackages = [ cfg.package ];
          systemd.user.services = toServiceAttrs cfg.devices;
        };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.razerbat = pkgs.callPackage "${dirs.packages}/razerbat.nix" { };
    };
}
