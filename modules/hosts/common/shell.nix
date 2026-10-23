{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) mkDefault mkIf;

      zsh = config.programs.zsh;
    in
    {
      programs.zsh.enable = mkDefault true;
      users.defaultUserShell = mkIf zsh.enable zsh.package;
    };
}
