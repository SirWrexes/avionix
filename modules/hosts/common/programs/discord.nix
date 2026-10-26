{
  flake.nixosModules.hosts =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # vesktop # TODO: make a wrapper with plugin configs
      ];
    };
}
