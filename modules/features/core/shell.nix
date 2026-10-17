{
  flake.nixosModules.core =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.core.shell;

      userName = config.core.user.name;
    in
    {
      users.defaultShell = pkgs.zsh;
      users.users.${userName}.useDefaultShell = true;
    };
}
