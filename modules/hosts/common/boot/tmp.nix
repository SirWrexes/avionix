{
  flake.nixosModules =
    { lib, config, ... }:
    let
      inherit (lib) mkDefault mkIf;
      inherit (config.users) user;

      TMPDIR = config.environment.sessionVariables.TMPDIR or "";
    in
    {
      # Make /tmp use RAM instead of disk
      boot.tmp = {
        useTmpfs = mkDefault true;
        tmpfsSize = mkDefault "50%";
        cleanOnBoot = mkDefault true;
      };

      # If /tmp is on RAM, move nix's temp dir for shells and builds to somewhere else on disk.
      # This is because RAM-bound TMPDIR can cause large builds to fail when full, e.g. after several days of uptime.
      environment.sessionVariables.TMPDIR = mkIf config.boot.tmp.useTmpfs (mkDefault "/var/tmp/nix");
      systemd.tmpfiles.settings."99-nix-tmpdir" = mkIf (TMPDIR != "") ({
        ${TMPDIR}.d = {
          group = "users";
          mode = "0755";
          user = "${user.name}";
          age = mkDefault "3d";
        };
      });
    };
}
