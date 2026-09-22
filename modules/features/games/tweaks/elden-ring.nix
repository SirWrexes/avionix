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
      width = builtins.toString config.display.primary.width;
      height = builtins.toString config.display.primary.height;

      concat = builtins.concatStringsSep " ";

      env = concat [
        "PROTON_FORCE_LARGE_ADDRESS_AWARE=1"
        "PROTON_NO_WM_DECORATION=1"
      ];

      baseFlags = [
        "--fullscreen"
        "--force-grab-cursor"
        "-w ${width}  -W ${width}"
        "-h ${height} -H ${height}"
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
