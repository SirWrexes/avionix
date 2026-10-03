# TODO: Make module options
#   - Search engines
#   - Extensions
#   - Login to Mozilla account with secrets?
{
  flake.nixosModules.desktop =
    { pkgs, lib, ... }:
    {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-bin;
      };
    };
}
