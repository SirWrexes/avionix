{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.gaming.platforms.steam;
    in
    {
      options.gaming.platforms.steam =
        let
          inherit (lib) types;
        in
        {
          launchOptions = lib.mkOption {
            type = types.attrsOf types.str;
            description = "Custom launch options for Steam games";
            example = {
              "1245620" = "gamescope --fullscreen --borderless -- %command%";
            };
            default = { };
            apply = builtins.toJSON;
          };
        };

      config =
        let
          activationScript = "steam-apply-launch-options";
        in
        lib.mkIf cfg.enable {
          system.userActivationScripts.${activationScript}.text = "${pkgs.writers.writePython3
            activationScript
            {
              flakeIgnore = [ "E501" ]; # pesky line length lints
              libraries = with pkgs.python314Packages; [ vdf ];
              makeWrapperArgs = [
                "--prefix"
                "PATH"
                ":"
                (lib.makeBinPath [
                  pkgs.procps
                ])
              ];
            }
            ''
              import json
              import subprocess
              import sys
              import time
              import vdf
              from pathlib import Path


              def is_steam_running():
                  res = subprocess.run(
                      ["pgrep", "-x", "steam"],
                      stdout=subprocess.DEVNULL,
                      stderr=subprocess.DEVNULL,
                  )
                  return res.returncode == 0


              was_running = is_steam_running()

              if was_running:
                  print("Steam is runnig. Attempting graceful shutdown...")
                  subprocess.run(["steam", "-shutdown"])
                  timeout = 10
                  start_time = time.time()
                  while is_steam_running():
                      if time.time() - start_time > timeout:
                          print("Taking too long. Kill it.")
                          subprocess.run(["pkill", "-9", "-x", "steam"])
                          break
                      time.sleep(0.5)

              steam_dir = Path.home() / ".local/share/Steam/userdata"
              if not steam_dir.exists():
                  print(f"Error: No Steam directorty found at {steam_dir}")
                  sys.exit(1)

              user_dirs = [d for d in steam_dir.iterdir() if d.is_dir and d.name.isdigit()]
              if not user_dirs:
                  print(f"Error: No Steam user directory found in {steam_dir}")
                  sys.exit(1)

              OPTIONS = json.load(open("${pkgs.writeText "options.json" cfg.launchOptions}"))

              for user_dir in user_dirs:
                  config_path = user_dir / "config/localconfig.vdf"
                  if not config_path.exists():
                      continue

                  print(f"Processing user config: {config_path}")

                  data = vdf.load(open(config_path))
                  apps = (
                      data.setdefault("UserLocalConfigStore", {})
                          .setdefault("Software", {})
                          .setdefault("Valve", {})
                          .setdefault("Steam", {})
                          .setdefault("apps", {})
                  )

                  modified = False
                  for app_id, app_opt in OPTIONS.items():
                      app_node = apps.setdefault(app_id, {})
                      if app_node["LaunchOptions"] != app_opt:
                          app_node["LaunchOptions"] = app_opt
                          print(f"Update app {app_id}: {app_opt}")
                          modified = True
                  if modified:
                      vdf.dump(data, open(config_path, "w"), pretty=True)
                      print(f"Successfully updated '{config_path}'!")
                  else:
                      print("Nothing to do.")

              if was_running:
                  print("Starting Steam...")
                  # Forced to use systemd-run to nuke std out/err or else Steam will polute the journal (journalctl)
                  subprocess.Popen(
                      [
                          "systemd-run",
                          "--user",
                          "--unit=steam-restarted-by-activation",
                          "--property=StandardOutput=null",
                          "--property=StandardError=null",
                          "--collect",
                          "steam",
                          "-silent"
                      ],
                      stdin=subprocess.DEVNULL,
                      stdout=subprocess.DEVNULL,
                      stderr=subprocess.DEVNULL,
                      start_new_session=True,
                  )
            ''
          }";
        };
    };
}
