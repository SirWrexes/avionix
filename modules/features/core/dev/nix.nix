{
  flake.nixosModules.dev =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.dev.nix;
    in
    {
      options.dev.nix = {
        enable = lib.mkEnableOption "Devtools for Nix" // {
          default = true;
        };

        formatter = lib.mkPackageOption pkgs "nixfmt" { };

        lsp = lib.mkPackageOption pkgs "nil" { };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          cfg.formatter
          cfg.lsp
        ];
      };
    };
}
