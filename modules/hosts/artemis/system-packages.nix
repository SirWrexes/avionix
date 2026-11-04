{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    lib.mkIf (config.host == "artemis") {
      environment.systemPackages = with pkgs; [
        me3
      ];
    };
}
