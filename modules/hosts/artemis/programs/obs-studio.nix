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
      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;
        plugins = with pkgs.obs-studio-plugins; [
          input-overlay
          obs-backgroundremoval
          obs-aitum-multistream
        ];
      };
    };
}
