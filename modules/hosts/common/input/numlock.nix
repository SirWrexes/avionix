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
        getExe
        getExe'
        mkDefault
        mkIf
        ;

      inherit (config.services.desktopManager) plasma6;
    in
    {
      # Force numlock on TTYs at boot
      systemd.services.numlock-on-boot = {
        enable = mkDefault true;
        description = "Enable numlock on all TTYs during early userspace";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "set-numlock" ''
            for tty in /dev/tty[0-9]; do
              ${getExe' pkgs.kbd "setleds"} -D +num < "$tty"
            done
          '';
        };
      };

      # Set numlock to be on by default in KDE session
      systemd.user.services.kdenumlock = mkIf plasma6.enable {
        wantedBy = [ "sysinit-reactivation.target" ];
        serviceConfig = {
          ExecStart = getExe (
            pkgs.writeShellScriptBin "kdenumlock" ''
              kwriteconfig6 --file kcminputrc --group Keyboard --key NumLock 0
            ''
          );
          Type = "oneshot";
        };
      };
    };
}
