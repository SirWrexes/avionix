import json
import os
import subprocess
import sys
import time
import vdf
from pathlib import Path

ENV_NAME_STEAM_DIR = "STEAMOPTS_STEAM_DIR"
ENV_NAME_OPTIONS_JSON = "STEAMOPTS_JSON"

STEAM_DIR_RAW = os.getenv(ENV_NAME_STEAM_DIR, "~/.local/share/Steam")


def info(msg, **kwargs):
    print(msg, **kwargs, file=sys.stdout)


def die(msg, **kwargs):
    print(f"\033[1;31mERROR: \033[0m{msg}", **kwargs, file=sys.stderr)
    sys.exit(1)


def ExpandedPath(raw):
    return (
        Path(os.path.expandvars(raw))
        .expanduser()
        .resolve()
    )


def smart_split(text):
    tokens = []
    current = []
    in_quote = None
    bracket_stack = []
    brackets = {"[": "]", "(": ")", "{": "}"}

    for char in text:
        if in_quote:
            current.append(char)
            if char == in_quote:
                in_quote = None
        elif bracket_stack:
            current.append(char)
            if char == bracket_stack[-1]:
                bracket_stack.pop()
            elif char in brackets:
                bracket_stack.append(brackets[char])
        else:
            if char.isspace():
                if current:
                    tokens.append("".join(current))
                    current = []
            elif char in ('"', "'"):
                in_quote = char
                current.append(char)
            elif char in brackets:
                bracket_stack.append(brackets[char])
                current.append(char)
            else:
                current.append(char)
    if current:
        tokens.append("".join(current))
    return tokens


def is_steam_running():
    res = subprocess.run(
        ["pgrep", "-x", "steam"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return res.returncode == 0


def shut_down_steam():
    info("Attempting graceful Steam shutdown...")
    subprocess.run(["steam", "-shutdown"])
    timeout = 5
    start_time = time.time()
    while is_steam_running():
        if time.time() - start_time > timeout:
            info("Taking too long. Kill it.")
            subprocess.run(["pkill", "-9", "-x", "steam"])
            break
        time.sleep(0.5)
    info("Steam is closed.")


def start_steam_without_std_logging():
    """Start Steam using systemd-run to completely nuke its logging to stdout/stderr.

    Steam and its web-based interface flood stdout/stderr.
    When launched from the desktop it's fine because you never see any of it.
    But this script is supposed to run from inside a service provided by a Nix module.
    When launched from inside a service, this logging goes to your journalctl and it's just unending pollution.
    """
    info("Launching Steam.")
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


def get_steamuser_dirs():
    userdata = ExpandedPath(STEAM_DIR_RAW) / "userdata"
    if not userdata.exists():
        die(f"Directory not found: '{userdata}'")
    if not userdata.is_dir():
        die(f"Not a directory: '{userdata}'")
    dirs = [d for d in userdata.iterdir() if d.is_dir() and d.name.isdigit()]
    if not dirs:
        die(f"No user directory found in '{userdata}'")
    return dirs


def load_options_json():
    path = os.getenv(ENV_NAME_OPTIONS_JSON)
    if path is None:
        die(f"Environment variable {ENV_NAME_OPTIONS_JSON} not found. Aborting.")
    path = ExpandedPath(path)
    if not os.path.isfile(path):
        die(f"File doesn't exist: '{path}'")
    if not os.access(path, os.R_OK):
        die(f"Can't read file: '{path}'")
    with open(path) as file:
        return json.load(file)


def get_app_name(id):
    default = f"APP:{id}"
    manifest = ExpandedPath(STEAM_DIR_RAW) / f"steamapps/appmanifest_{id}.acf"
    if not (os.access(manifest, os.R_OK) and manifest.is_file()):
        return default
    with open(manifest) as file:
        data = vdf.load(file)
        return data.get("AppState", {}).get("name") or default


def get_user_name(localconfig, uid):
    return (
        localconfig
        .get("UserLocalConfigStore", {})
        .get("friends", {})
        .get("PersonaName")
    ) or f"USER:{uid}"


OPTIONS = load_options_json()
steamuser_dirs = get_steamuser_dirs()
was_running = is_steam_running()

if was_running:
    shut_down_steam()

for user_dir in steamuser_dirs:
    config_path = user_dir / "config/localconfig.vdf"
    if not config_path.exists():
        continue

    with open(config_path) as config_file:
        data = vdf.load(config_file)
        user = get_user_name(data, user_dir.name)
        info(f"Processing Steam config for {user}")
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
            if app_node.get("LaunchOptions") == app_opt:
                continue
            app_node["LaunchOptions"] = app_opt
            info(f"\n=>> \033[7m{get_app_name(app_id)}\033[0m")
            for part in smart_split(app_opt):
                info(f"    > \033[1m{part}\033[0m")
            info("\n")
            modified = True
        if modified:
            with open(config_path, "w") as config_file:
                vdf.dump(data, config_file, pretty=True)
            info(f"Successfully updated '{config_path}'!")
        else:
            info("Nothing to do.")

if was_running:
    start_steam_without_std_logging()
