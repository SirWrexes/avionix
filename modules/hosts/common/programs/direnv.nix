{
  flake.nixosModules.hosts =
    { lib, config, ... }:
    let
      inherit (lib) mkDefault;
      inherit (config) flake;
    in
    {
      programs.direnv = {
        enable = mkDefault true;
        settings.whitelist.exact = [ "${flake.root}/.envrc" ];
      };
    };
}
