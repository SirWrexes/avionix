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
        flake = builtins.toString flakePath;
      };

      environment.sessionVariables = rec {
        # Takes precedence over NH_FLAKE (programs.nh.flake) for `nh os` commands
        NH_OS_FLAKE = "${flakePath}#nixosConfigurations.${hostName}";
        FLAKE_HOME = "${flakePath}";
        FLAKE_PACKAGES = "${flakePath}#packages.${pkgs.stdenv.hostPlatform.system}";
      };
    };
}
