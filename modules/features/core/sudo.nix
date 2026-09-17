{ self, inputs, ... }:
{
  flake.nixosModules.core =
    { pkgs, ... }:
    {
      security.sudo.package = self.packages.${pkgs.stdenv.hostPlatform.system}.sudo;
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.sudo = pkgs.sudo.override { withInsults = true; } // {
        name = "sudo+insults";
      };
    };
}
