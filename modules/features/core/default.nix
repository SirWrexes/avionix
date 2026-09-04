{ self, inputs, ... }:
{
  flake.nixosModules.core = { pkgs, config, lib, ... }:
  {
    imports = [
      self.nixosModules.bootloader
      self.nixosModules.fonts
      self.nixosModules.locale
      self.nixosModules.nh
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "26.05"; # Did you read the comment?

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
