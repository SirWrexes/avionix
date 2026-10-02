{
  self,
  inputs,
  packagesDir,
  ...
}:
{
  flake.nixosModules.gaming =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.gaming.games.devilutionx;
    in
    {
      options.gaming.games.devilutionx =
        let
          inherit (lib) types;
        in
        {
          enable = lib.mkEnableOption "DevilutionX";

          gameFiles = lib.mkOption {
            type = types.listOf types.path;
            description = ''
              Game files for DevilutionX.

              See https://github.com/diasurgical/DevilutionX#how-to-install
            '';
            example = [ ./path/to/DIABDAT.MPQ ];
            default = [ ];
          };
        };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          (self.packages.${pkgs.stdenv.hostPlatform.system}.devilutionx.override {
            inherit (cfg) gameFiles;
          })
        ];
      };
    };

  perSystem =
    { lib, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "devilutionx" ];
      };
    in
    {
      packages.devilutionx = pkgs.callPackage "${packagesDir}/devilutionx.nix" { };
    };
}
