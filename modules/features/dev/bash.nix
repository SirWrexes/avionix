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
        mkIf
        mkPackageOption
        ;

      cfg = config.dev.bash;
    in
    {
      options.dev.bash = {
        enable = mkEnableOption "Devtools for Nix" // {
          default = true;
        };
        languageServer = mkPackageOption pkgs "bash-language-server" { };
        linter = mkPackageOption pkgs "shellcheck" { };
        formatter = mkPackageOption pkgs "shfmt" { };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = with cfg; [
          languageServer
          linter
          formatter
        ];
      };
    };
}
