{ self, inputs, ... }:
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
      options.gaming.games.devilutionx.enable = lib.mkEnableOption "DevilutionX";

      config = lib.mkIf cfg.enable {
        nixpkgs.config.allowUnfree = true;
        environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.devilutionx ];
      };
    };

  perSystem =
    {
      self',
      lib,
      system,
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "devilutionx" ];
      };
    in
    {
      packages.devilutionx = pkgs.symlinkJoin {
        name = "devilutionx+mpqs";
        paths = [ pkgs.devilutionx ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild =
          let
            packs = [
              ./DIABDAT.MPQ
              ./hellfire.mpq
              ./hfmonk.mpq
              ./hfmusic.mpq
              ./hfvoice.mpq
            ];

            linkPack = pack: "ln -sf ${pack} $out/share/diasurgical/devilutionx/${builtins.baseNameOf pack}";
          in
          ''
            ${builtins.concatStringsSep "\n" (builtins.map linkPack packs)}
          '';
      };
    };
}
