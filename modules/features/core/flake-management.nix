{ self, inputs, ... }:
{
  flake.nixosModules.core =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (config.core) flakePath hostName system;
    in
    {
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 7d --keep 3";
        flake = with config.core; "${flakePath}#nixosConfigurations.${hostName}";
      };

      environment.sessionVariables = rec {
        FLAKE_HOME = "${flakePath}";
        FLAKE_PACKAGES = "${flakePath}#packages.${pkgs.stdenv.hostPlatform.system}";
      };
    };
}
