{
  flake.nixosModules.programs =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        mkEnableOption
        mkIf
        mkPackageOption
        ;

      cfg = config.programs.modEngine3;
    in
    {
      # TODO: Make profile management
      # TODO: Make plugin unpacker - embed lib in readOnly option
      options.programs.modEngine3 = {
        enable = mkEnableOption "ModEngine3 mod manager for FromSoftware games";
        package = mkPackageOption pkgs "me3" { };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];
      };
    };
}
