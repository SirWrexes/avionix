{ ... }:
{
  flake.nixosModules.core = { pkgs, lib, ... }:
  {
    systemd.services.numlock-on-boot = {
      description = "Enable numlock during early userspace";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "set-numlock" ''
          for tty in /dev/tty[0-9]; do
            ${pkgs.kbd}/bin/setleds -D +num < "$tty"
          done
        '';
      };
    };
  };
}
