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
        optional
        ;

      inherit (config.programs)
        obs-studio
        ;
    in
    {
      environment.systemPackages =
        with pkgs;
        (
          [

            vesktop # TODO: make a wrapper with plugin configs
            discord-gamesdk
            arrpc
          ]
          # Vesktop RPC doesn't seem to work with https://reactive.fugi.tech
          ++ (optional obs-studio.enable discord)
        );
    };
}
