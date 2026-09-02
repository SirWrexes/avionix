{ ... }:
{
  flake.nixosModules.common = { config, pkgs, ... }:
  {
    # Enable flake support.
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Hibernation settings
    # TODO: Isolate power management into its own module with options
    powerManagement.enable = true;
    boot.resumeDevice = (builtins.head config.swapDevices).device;
    systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";
 
    # Don't be a caveman.
    networking.networkmanager.enable = true;
  
    # Doxx yourself.
    time.timeZone = "Europe/Paris";
  
    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };

    # Let us have all the nice fonts and never see tofu
    fonts.fontconfig.useEmbeddedBitmaps = true;
    fonts.packages = 
        with pkgs;
        let
          nerd-fonts' = builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts);
        in
        nerd-fonts' ++ [
          noto-fonts-color-emoji
          noto-fonts-cjk-sans
        ];
  
    # Configure keymap in X11 (and basically everything else).
    services.xserver.xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
  
    # Define a user account.
    # Don't forget to set a password with ‘passwd’ if not done during installation !
    users.users."wrexes" = {
      isNormalUser = true;
      description = "Sir Wrexes";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
      initialPassword = "changeme";
    };

    # Absolute essential packages
    environment.systemPackages = with pkgs; [
      bat
      git
      neovim
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
