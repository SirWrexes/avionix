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
      programs.me3.profiles."Seamless Co-op".settings = {
        enable = false;

        supports = [ "eldenring" ];

        natives = with pkgs.me3Packages.eldenring; {
          ersc = {
            path = seamless-coop.override { settings.cooppassword = "4"; };
            load_early = true;
          };
        };
      };
    };
}
