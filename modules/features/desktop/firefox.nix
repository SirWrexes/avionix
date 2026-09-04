{ self, inputs, config, ... }:
{
  flake.nixosModules.firefox = { config, pkgs, ... }:
  {
    programs.firefox = { 
      enable = true;
      # TODO make an actual wrapper (none exist yet)
      # package = self.packages.${pkgs.stdenv.hostPlatform.system}.wrx-firefox;
    };
  };

  # perSystem = { pkgs, lib, self', ...}:
  # {
  #   packages.wrx-firefox = inputs.wrapper-modules.[someLibFunctionToWrapFirefox] {

  #     inherit pkgs;

  #     # TODO: Configure extensions here.
  #     # TODO: Make custom config to remove tab-bar and have Tree Style Tabs be the default.
  #   };
  # };
}
