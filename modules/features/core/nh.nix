{ self, inputs, ... }:
{
  flake.nixosModules.nh = { config, pkgs, lib, ... }:
  {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 3";
      flake = "${config.users.users.wrexes.home}/.config/nixos#${config.networking.hostName}";
    };
  };
}
