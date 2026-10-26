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
        mkIf
        ;
    in
    mkIf (config.host == "artemis") {
      hardware.openrazer = {
        enable = true;
        users = [ config.users.user.name ];
      };

      services.razerbat = {
        enable = true;
        devices = [ "Razer Naga V2 HyperSpeed" ];
      };

      services.input-remapper = {
        enable = true;
        configDir = "${config.flake.root}/modules/hosts/artemis/input-remapper";
      };

      display.monitors =
        let
          iiyama = device: {
            inherit device;
            width = 3440;
            height = 1440;
            refreshRate = 165;
          };
        in
        [
          ((iiyama "DP-1") // { primary = true; })
          (iiyama "DP-2")
        ];
    };
}
