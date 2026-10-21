{
  flake.nixosModules.core =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (config) host;
      inherit (config.core) flakePath;

      cfg = config.core.flake.nh;
    in
    {
      options.core.flake.nh = {
        enable = lib.mkEnableOption "nh nix wrapper" // {
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        programs.nh = {
          inherit (cfg) enable;

          clean.enable = true;
          clean.extraArgs = builtins.concatStringsSep " " [
            "--keep-since 7d"
            "--keep 3"
            "--optimise"
          ];
          flake = builtins.toString flakePath;
        };

        environment.sessionVariables = {
          # Takes precedence over NH_FLAKE (programs.nh.flake) for `nh os` commands
          NH_OS_FLAKE = "${flakePath}#nixosConfigurations.${host}";
        };
      };
    };
}
