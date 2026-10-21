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
      options.dev.bash = {
        enable = lib.mkEnableOption "Devtools for Nix" // {
          default = true;
        };
        languageServer = lib.mkPackageOption pkgs "bash-language-server" { };
        linter = lib.mkPackageOption pkgs "shellcheck" { };
        formatter = lib.mkPackageOption pkgs "shfmt" { };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with cfg; [
          languageServer
          linter
          formatter
        ];
      };
    };
}
