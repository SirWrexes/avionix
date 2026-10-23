{
  flake.nixosModules.dev =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkIf
        ;

      cfg = config.dev.nix;
    in
    {
      options.dev.nix = {
        enable = mkEnableOption "Devtools for Nix" // {
          default = true;
        };
        languageServer = mkPackageOption pkgs "nil" { };
        formatter = mkPackageOption pkgs "nixfmt" { };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = with cfg; [
          languageServer
          formatter
        ];
      };
    };
}
