{ inputs, ... }:
{
  flake.nixosModules.pkgsNoCuda =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (config.nixpkgs.config) allowUnfree;
    in
    {
      _module.args.pkgsNoCuda =
        (import inputs.nixpkgs {
          inherit system;
          config = {
            inherit allowUnfree;
            cudaSupport = false;
          };
        }).pkgs;
    };
}
