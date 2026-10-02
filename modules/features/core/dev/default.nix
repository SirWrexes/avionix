{
  flake.nixosModules.dev = { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [ universal-ctags ];
  };
}
