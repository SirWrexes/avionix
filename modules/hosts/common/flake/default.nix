{ self, description, ... }:
{
  flake.nixosModules.hosts =
    { lib, config, ... }:
    let
      inherit (lib)
        mkDefault
        ;
    in
    {
      flake = {
        inherit self;
        name = description;
        root = mkDefault "${config.users.user.home}/.config/nixos";
      };

      environment.sessionVariables = {
        NIX_CONF_DIR = mkDefault config.flake.root;
        TMPDIR = mkDefault "/tmp/nix";
      };
    };
}
