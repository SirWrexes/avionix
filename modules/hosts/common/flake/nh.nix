{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) concatStringsSep mkDefault;
      inherit (config) host flake;
    in
    {
      programs.nh = {
        enable = mkDefault true;
        flake = flake.root;
        clean.enable = mkDefault true;
        clean.extraArgs = mkDefault (
          concatStringsSep " " [
            "--keep-since 7d"
            "--keep 3"
            "--optimise"
          ]
        );
      };
      environment.variables = {
        # Takes precedence over NH_FLAKE (programs.nh.flake) for `nh os` commands
        NH_OS_FLAKE = mkDefault "${flake.root}#nixosConfigurations.${host}";
      };
    };
}
