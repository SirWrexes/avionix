# TODO: Make module options
#   - Search engines
#   - Extensions
#   - Login to Mozilla account with secrets?
{
  flake.nixosModules.hosts =
    {
      pkgs,
      config,
      ...
    }:
    let
      # Firefox has been building from source every time with CUDA support enabled.
      # This has resulted in OOMs 9/10 times and I gave up on hoping it's ever cached properly.
      inherit (config) pkgsWithoutCuda;
      cudaSupport = config.nixpkgs.config.cudaSupport or false;
    in
    {
      programs.firefox = {
        enable = false;
        package = with if cudaSupport then pkgsWithoutCuda else pkgs; firefox;
      };
    };
}
