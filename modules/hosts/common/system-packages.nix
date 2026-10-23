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
        fd
        ripgrep
        bat
        btop
        lazygit
        wl-clipboard
      ];
    };
}
