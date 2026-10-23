{ inputs, ... }:
{
  flake.nixosModules.pkgsWithoutCuda =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options =
        let
          inherit (lib) types;
          inherit (pkgs.stdenv.hostPlatform) system;
          inherit (config.nixpkgs.config) allowUnfree;
        in
        {
          pkgsWithoutCuda = lib.mkOption {
            type = with types; attrs; # I'm not safely typing nixpkgs lmao, I still have a semblance of life
            description = ''
              An instance of `nixpkgs.pkgs` with CUDA support disabled.
              Used for packages that get some slow caching into nixos-cuda, resulting in building and going OOM.
              I'm looking at you, Firefox!
            '';
            readOnly = true;
            default =
              (import inputs.nixpkgs {
                inherit system;
                config = {
                  inherit allowUnfree;
                  cudaSupport = false;
                };
              }).pkgs;
          };
        };
    };
}
