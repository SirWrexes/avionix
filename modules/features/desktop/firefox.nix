{ ... }:
{
  flake.nixosModules.desktop =
    { lib, config, ... }:
    {
      programs.firefox = {
        enable = true;
        # TODO make a fully configured wrapper
        # It gets annoying having to reconfigure the most basic settings every time I reinstall it.
      };
    };
}
