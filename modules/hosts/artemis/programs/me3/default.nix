{ self, ... }:
{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        mkIf
        ;
    in
    mkIf (config.host == "artemis") {
      programs.me3.enable = true;
      nixpkgs.overlays = [ self.overlays.me3Packages ];
    };
}
