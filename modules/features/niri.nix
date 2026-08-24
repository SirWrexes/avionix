{ self, inputs, config, ... }:
{
  flake.nixosModules.niri = { pkgs, lib, ... }:
  let pkg-niri = self.packages.${pkgs.stdenv.hostPlatform.system}.wrx-niri; in
  {
    programs.niri = {
      enable = true;
      package = pkg-niri;

      useNautilus = true;
    };

    # services.displayManager.ly.enable = true;

    # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
    # unit which shadows the imported user-manager PATH. Disabling the default
    # lets niri inherit the full PATH set up by niri-session.
    # systemd.user.services.niri.enableDefaultPath = false;

    # security.polkit.enable = true;
    # services.gnome.gnome-keyring.enable = true;
    # security.pam.services.swaylock = {};
  };

  perSystem = { pkgs, lib, self', ... }:
  {
    packages.wrx-niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;

      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.wrx-noctalia)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard.xkb = {
          layout = "us";
          variant = "altgr-intl";
        };

        layout.gaps = 5;

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
          "Mod+Escape".close-window = _ : {};
          "Mod+Equal".spawn-sh = "${lib.getExe self'.packages.wrx-noctalia} ipc call launcher toggle";
        };
      };
    };
  };
}
