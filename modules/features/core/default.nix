{ ... }:
{
  flake.nixosModules.core = { pkgs, ... }:
  {
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    networking.networkmanager.enable = true;

    environment.systemPackages = with pkgs; [
      bat
      btop
      git
      lazygit
      neovim
    ];

    # Might want to move that to a users/ module dir at some point
    # Don't forget to set a password with ‘passwd’ if not done during installation !
    users.users."wrexes" = {
      isNormalUser = true;
      description = "Sir Wrexes";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
      initialPassword = "changeme";
    };
  };
}
