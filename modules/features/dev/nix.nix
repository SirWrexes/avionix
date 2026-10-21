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

        lsp = lib.mkPackageOption pkgs "nil" { };

        formatter = lib.mkPackageOption pkgs "nixfmt" { };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with cfg; [
          lsp
          formatter
        ];
      };
    };
}
