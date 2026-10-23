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
        getExe'
        mkDefault
        mkIf
        ;

      inherit (config.services.desktopManager) plasma6;
    in
    {
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

      system.userActivationScripts.kdeNumlock = mkIf plasma6.enable {
        text = ''
          kwriteconfig6 --file kcminputrc --group Keyboard --key NumLock 0
        '';
      };
    };
}
