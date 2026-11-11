{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        bat
        btop
        fd
        lazygit
        ripgrep
        tree
        wl-clipboard
      ];
    };
}
