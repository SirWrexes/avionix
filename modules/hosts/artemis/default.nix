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
        mkIf
        ;
    in
    mkIf (config.host == "artemis" && false) {
      hardware.openrazer = {
        enable = true;
        users = [ config.users.user.name ];
        packages.kernel =
          let
            kp = config.boot.kernelPackages;
            moduleBuildDir = "${kp.kernel.dev}/lib/modules/${kp.kernel.modDirVersion}/build";
          in
          # Backport of NixOS/nixpkgs#576293 — drop once it reaches nixos-unstable.
          kp.openrazer.overrideAttrs (old: {
            makeFlags = old.makeFlags ++ [
              "INSTALL_MOD_PATH=${placeholder "out"}"
              "INSTALL_MOD_DIR=kernel/drivers/hid"
              "INSTALL_MOD_STRIP=1"
              "DEPMOD=true"
            ];
            installTargets = [ "modules_install" ];
            installFlags = [
              "-C"
              moduleBuildDir
              "M=$(PWD)/driver"
            ];
            installPhase = null;
            postInstall = ''
              RAZER_MOUNT_OUT="$out/bin/razer_mount"
              RAZER_RULES_OUT="$out/etc/udev/rules.d/99-razer.rules"
              install -m 644 -v -D install_files/udev/99-razer.rules $RAZER_RULES_OUT
              install -m 755 -v -D install_files/udev/razer_mount $RAZER_MOUNT_OUT
              substituteInPlace $RAZER_RULES_OUT \
                --replace razer_mount $RAZER_MOUNT_OUT \
                --replace plugdev openrazer
              substituteInPlace $RAZER_MOUNT_OUT \
                --replace /usr/bin/logger ${pkgs.util-linux}/bin/logger \
                --replace chgrp ${pkgs.coreutils}/bin/chgrp \
                --replace "PATH='/sbin:/bin:/usr/sbin:/usr/bin'" "" \
                --replace plugdev openrazer
            '';
          });
      };

      services.razerbat = {
        enable = false;
        devices = [ "Razer Naga V2 HyperSpeed" ];
      };

      services.input-remapper = mkIf false {
        enable = true;
        configDir = "${config.flake.root}/modules/hosts/artemis/input-remapper";
      };

      display.monitors =
        let
          iiyama = device: {
            inherit device;
            width = 3440;
            height = 1440;
            refreshRate = 165;
          };
        in
        [
          ((iiyama "DP-1") // { primary = true; })
          (iiyama "DP-2")
        ];
    };
}
