{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.artemis = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      core
      desktop
      gaming

      artemis
    ];
  };

  flake.nixosModules.artemis =
    { pkgs, config, ... }:
    {
      core.hostName = "artemis";
      core.user = self.users.wrexes;

      hardware.openrazer = {
        enable = true;
        users = [ config.core.user.name ];
      };

      services.razerbat = {
        enable = true;
        devices = [ "Razer Naga V2 HyperSpeed" ];
      };

      services.input-remapper = {
        enable = true;
        configDir = "${config.core.flakePath}/modules/hosts/artemis/input-remapper";
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
