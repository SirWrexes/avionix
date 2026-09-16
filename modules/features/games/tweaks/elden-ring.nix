{ self, inputs, ... }:
{
  flake.nixosModules.gaming = { pkgs, lib, config, ... }:
  {
    systemd.user.services.steam-tweak-elden-ring = {
      description = "Improve performance for Elden Ring";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let
          flags = [
            "--fullscreen"
            "--borderless"
          ] ++ (if config.gaming.tools.mangohud.enable then [
            "--unfocused-fps 30"
            "--mangoapp"
          ] else []);

          flagsStr = builtins.concatStringsSep " " flags;
        in pkgs.writers.writePython3 "steam-tweak-elden-ring" {
            libraries = [ pkgs.python314Packages.vdf ];
          } ''
            import vdf
            from pathlib import Path

            app = "1245620"
            opt = "gamescope ${flagsStr} -- %command%"

            steam_dir = Path.home() / ".local/share/Steam/userdata"
            if not steam_dir.exists():
                print(f"Error: No Steam directory found at {steam_dir}")

            user_dirs = [d for d in steam_dir.iterdir() if d.is_dir() and d.name.isdigit()]
            if not user_dirs:
                print("Error: No Steam user data dir found")

            for user_dir in user_dirs:
                config_path = user_dir / "config/localconfig.vdf"
                if not config_path.exists():
                    continue

                print(f"Processing: {config_path}")

                data = vdf.load(open(config_path))
                apps = (
                    data.setdefault("UserLocalConfigStore", {})
                        .setdefault("Software", {})
                        .setdefault("Valve", {})
                        .setdefault("Steam", {})
                        .setdefault("apps", {})
                )

                modified = False
                app_node = apps.setdefault(app, {})
                if app_node["LaunchOptions"] != opt:
                    app_node["LaunchOptions"] = opt
                    print(f"Update {app}: {opt}")
                    modified = True

                if modified:
                    vdf.dump(data, open(config_path, "w"), pretty=True)
                    print("Succesfully updated `localconfig.vdf`!")
                else:
                    print("Nothing to do.")
          '';
      };
    };
  };
}
