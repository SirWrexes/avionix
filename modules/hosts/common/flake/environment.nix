{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        mkDefault
        mkIf
        ;

    in
    {
      environment.sessionVariables = {
        NIX_CONF_DIR = mkIf (config ? flake) (mkDefault config.flake.root);
        TMPDIR = mkDefault "/tmp/nix";
      };
    };
}
