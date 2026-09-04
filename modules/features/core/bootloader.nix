{ self, inputs, ... }:
{
  flake.nixosModules.bootloader = { config, pkgs, ... }:
  {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
