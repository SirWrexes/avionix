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
    # Tried the default for a while...
    # I think I prefer uncofigured Bash over unconfigured Zsh.
    # TODO: Come back to this and get a fancy customised shell. Maybe. One day.
    mkIf false {
      programs.zsh.enable = mkDefault true;
      users.defaultUserShell = mkIf zsh.enable (zsh.package or pkgs.zsh);
    };
}
