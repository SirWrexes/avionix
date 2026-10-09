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
            type = with types; listOf (either str path);
            description = ''
              Game files for DevilutionX.

              See https://github.com/diasurgical/DevilutionX#how-to-install
              For licensig reason, it is recommended not to push this in a git repo.
              Instead, use a secret management solution.

            '';
            example = [ "\${./.}/games/devilutionx/DIABDAT.MPQ" ];
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
      # TODO: Find a way to do this without instatiating a new nixpkgs instance every time.
      # See https://zimbatm.com/notes/1000-instances-of-nixpkgs/
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "devilutionx" ];
      };
    in
    {
      packages.devilutionx = pkgs.callPackage "${packagesDir}/devilutionx.nix" { };
    };
}
