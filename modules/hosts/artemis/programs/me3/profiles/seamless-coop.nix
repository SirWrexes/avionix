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
        supports = [ "eldenring" ];

        natives = with pkgs.me3Packages; {
          ersc = {
            path = er-seamless-coop.override { settings.cooppassword = "4"; };
            load_early = true;
          };
        };
      };
    };
}
