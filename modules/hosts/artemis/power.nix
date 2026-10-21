# TODO: Find a way to stop NVidia from crashing everything on sleep
{
  flake.nixosModules.hosts =
    { lib, config, ... }:
    lib.mkIf (config.host == "artemis") {
      powerManagement.enable = true;

      hardware.nvidia.powerManagement.enable = true;

      systemd.sleep.settings.Sleep = {
        AllowSuspend = "no";
        AllowHibernate = "no";
      };
    };
}
