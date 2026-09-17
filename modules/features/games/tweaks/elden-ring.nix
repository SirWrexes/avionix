{ self, inputs, ... }:
{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      concat = builtins.concatStringsSep " ";

      env = concat [
        "PROTON_FORCE_LARGE_ADDRESS_AWARE=1"
        "PROTON_NO_WM_DECORATION=1"
      ];

      baseFlags = [
        "--fullscreen"
        "--force-grab-cursor"
        "-w 3440 -W 3440" # TODO: Make some per-host monitor definition setting
        "-h 1440 -H 1440" # TODO: Make some per-host monitor definition setting
      ];

      mangoFlags = lib.optionals config.gaming.tools.mangohud.enable [
        "--mangoapp"
      ];

      flags = concat (baseFlags ++ mangoFlags);
    in
    {
      gaming.platforms.steam.launchOptions."1245620" =
        "${env} ${lib.getExe pkgs.gamescope} ${flags} -- %command%";
    };
}
