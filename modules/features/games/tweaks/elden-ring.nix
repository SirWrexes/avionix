{ self, inputs, ... }:
{
  flake.nixosModules.gaming = { pkgs, lib, config, ... }:
  let
    concat = builtins.concatStringsSep " ";

    env = concat [
      "PROTON_FORCE_LARGE_ADDRESS_AWARE=1"
      "PROTON_NO_WM_DECORATION=1"
    ];

    baseFlags = [
      "--fullscreen"
      "--borderless"
    ];

    mangoFlags = if !config.gaming.tools.mangohud.enable
      then []
      else [
        "--unfocused-fps 30"
        "--mangoapp"
      ];

    flags = concat (baseFlags ++ mangoFlags);
  in
  {
    gaming.platforms.steam.launchOptions."1245620" = "${env} ${lib.getExe pkgs.gamescope} ${flags} -- %command%";
  };
}
