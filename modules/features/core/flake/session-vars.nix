{
  flake.nixosModules.core =
    { config, ... }:
    let
      inherit (config.core) flakePath system;
    in
    {
      environment.sessionVariables = {
        FLAKE_HOME = "${flakePath}";
        FLAKE_PACKAGES = "${flakePath}#packages.${system}";
      };
    };
}
