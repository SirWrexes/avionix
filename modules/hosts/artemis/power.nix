
{ self, inputs, ... }:
{
  flake.nixosModules.artemis-power = { config, pkgs, lib, ... }:
  {
    powerManagement.enable = true;
    hardware.nvidia.powerManagement.enable = false;

    systemd.sleep.settings.Sleep = {
      AllowSuspend = "yes";
      AllowHibernate = "no"; # Fix this crashing on resume BS
    };
  };
}
