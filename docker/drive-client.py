#!/usr/bin/env python3
"""Walks a real Counter-Strike 1.6 client through the CoD Mod menus.

Everything is driven from the server: rcon calls cod_drive, which stuffs client
commands into the connected player. AMXX menus are picked with `menuselect`,
the login prompts are ordinary client commands, and `cancelselect` closes an
open menu or MOTD. Nothing is ever typed into the desktop, so no keystroke can
escape into another window - the only thing done on the X server is capturing
the game window with `import`.

Each step is screenshotted, and the server log is checked for SQL errors at the
end, which is what makes this a pass/fail check rather than a slideshow.

Usage:
    docker compose up -d server
    python3 docker/drive-client.py [--out DIR] [--keep-client]
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from rcon import Rcon  # noqa: E402

HALF_LIFE = Path(
    os.environ.get(
        "HALF_LIFE_DIR",
        Path.home() / ".local/share/Steam/steamapps/common/Half-Life",
    )
)
PLAYER_NAME = "Zolnierz"
PLAYER_PASSWORD = "secret1"
SERVER = "127.0.0.1:27015"
CONTAINER = "codmod-server-1"
COMPOSE = Path(__file__).resolve().parent / "docker-compose.yml"
LOG = "/home/steam/hlds/cstrike/addons/amxmodx/logs/cod_mod.log"

# label, client commands to stuff, seconds to settle before the screenshot
STEPS = [
    ("account-login", [f"WPROWADZ_SWOJE_HASLO {PLAYER_PASSWORD}"], 2.0),
    ("team-join", ["jointeam 1"], 2.0),
    ("class-menu", ["klasa"], 1.5),
    ("class-selected", ["menuselect 1"], 2.5),
    ("classes-motd", ["cancelselect", "klasy"], 2.5),
    ("level-top15", ["cancelselect", "top"], 3.5),
    ("knife-menu", ["cancelselect", "noze"], 1.5),
    ("knife-selected", ["menuselect 5"], 2.0),
    ("hud-menu", ["cancelselect", "hud"], 1.5),
    ("mission-menu", ["cancelselect", "misje"], 1.5),
    ("exchange-menu", ["cancelselect", "wymien"], 1.5),
    ("clan-menu", ["cancelselect", "klan"], 2.5),
    ("clan-members", ["menuselect 1"], 3.0),
    ("clan-top15", ["cancelselect", "klan", "menuselect 6"], 3.5),
    ("stats-menu", ["cancelselect", "menustaty"], 1.5),
    ("time-top15", ["cancelselect", "topczas"], 3.5),
    ("stats-top15", ["cancelselect", "topstaty"], 3.5),
    ("medals-top15", ["cancelselect", "medale"], 3.5),
    ("free-honor", ["cancelselect", "freehonor"], 2.0),
    ("done", ["cancelselect"], 1.0),
]

WHO = re.compile(r"id=(\d+) name=(.+?) db_id=(\d+) honor=(-?\d+) account=(\d+)")


def sh(*command, check=False):
    return subprocess.run(command, capture_output=True, text=True, check=check).stdout


def game_window():
    for line in sh("wmctrl", "-lx").splitlines():
        if "hl_linux" in line:
            return line.split()[0]

    return None


# Matched on the full path: a bare "hl_linux" pattern also matches the command
# line of whatever shell is running pkill, which then kills itself.
CLIENT_PATTERN = str(HALF_LIFE / "hl_linux")


def client_running():
    return bool(sh("pgrep", "-f", CLIENT_PATTERN).strip())


def stop_client():
    """Steam silently ignores -applaunch while the game is still running, and a
    window that has not been destroyed yet looks like a live client, so wait for
    both to go away before returning."""
    for signal in ("-TERM", "-KILL"):
        if not client_running() and not game_window():
            break

        subprocess.run(["pkill", signal, "-f", CLIENT_PATTERN], check=False)

        for _ in range(20):
            if not client_running() and not game_window():
                break

            time.sleep(1)

    # give Steam a moment to notice the app exited
    time.sleep(5)


def restart_server(rcon):
    """A client killed without disconnecting leaves its slot occupied, and the
    next connection then hangs on "Establishing network connection", so every
    run starts from a fresh server."""
    print("restarting server")

    subprocess.run(
        ["docker", "compose", "-f", str(COMPOSE), "restart", "server"],
        capture_output=True,
        check=False,
    )

    wait_for(lambda: "hostname" in rcon.command("status"), "the server", timeout=180)


def launch_client():
    """Starts the game through Steam so the runtime libraries resolve."""
    print("launching client")

    subprocess.Popen(
        [
            "setsid", "steam", "-applaunch", "10",
            "-console", "-window", "-width", "1280", "-height", "720", "-novid",
            "+name", PLAYER_NAME,
            "+connect", SERVER,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )


def wait_for(condition, what, timeout=120, interval=3):
    deadline = time.time() + timeout

    while time.time() < deadline:
        result = condition()

        if result:
            return result

        time.sleep(interval)

    raise TimeoutError(f"timed out waiting for {what}")


def who(rcon):
    """Returns the connected players as parsed by the test plugin."""
    return WHO.findall(rcon.command("cod_who"))


def screenshot(window, out, label, index):
    path = out / f"{index:02d}-{label}.png"

    subprocess.run(["import", "-window", window, str(path)], check=False)

    return path


def server_errors(since):
    log = sh("docker", "exec", CONTAINER, "sh", "-c", f"cat {LOG} 2>/dev/null")
    lines = log.splitlines()

    return [l for l in lines[since:] if "query failed" in l.lower() or "SQL" in l], len(lines)





def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default=None, help="screenshot directory")
    parser.add_argument("--keep-client", action="store_true", help="leave the game running")
    args = parser.parse_args()

    if not (HALF_LIFE / "hl_linux").exists():
        sys.exit(f"Counter-Strike 1.6 not found in {HALF_LIFE}")

    if not shutil.which("import") or not shutil.which("wmctrl"):
        sys.exit("needs imagemagick and wmctrl")

    out = Path(args.out or tempfile.mkdtemp(prefix="codmod-shots-"))
    out.mkdir(parents=True, exist_ok=True)

    rcon = Rcon()

    stop_client()
    restart_server(rcon)

    # The login timeout would kick the player in the middle of the walk.
    rcon.command("cod_accounts_login_max_time 900")

    _, log_length = server_errors(0)

    # A client left over from an earlier run sits on the main menu after the
    # server restarts, and `retry` cannot be sent without keyboard input, so the
    # only reliable way back in is a fresh launch with +connect.
    players = None

    for attempt in range(1, 4):
        # A client that is already up may be sitting on a disconnect dialog, and
        # there is no way to press Close without keyboard input, so start clean.
        stop_client()
        launch_client()

        try:
            window = wait_for(game_window, "the game window", timeout=180)
            print(f"game window {window}")

            players = wait_for(lambda: who(rcon), "the client to connect", timeout=120)
            break
        except TimeoutError:
            print(f"attempt {attempt}: client did not join")

    if not players:
        sys.exit("client never connected")

    player_id, name, db_id, honor, account = players[0]

    print(f"player {player_id} '{name}' db_id={db_id} honor={honor} account={account}")

    if name != PLAYER_NAME:
        print(f"warning: connected as '{name}', expected '{PLAYER_NAME}'")

    for index, (label, commands, settle) in enumerate(STEPS, start=1):
        for command in commands:
            rcon.command(f"cod_drive {player_id} {command}")
            time.sleep(0.4)

        time.sleep(settle)

        window = game_window() or window
        path = screenshot(window, out, label, index)

        print(f"  {index:02d} {label:<16} {path.name}")

    failures = []
    players = who(rcon)

    if not players:
        failures.append("the player dropped during the walk")
    else:
        player_id, name, db_id, honor, account = players[0]
        print(f"after: '{name}' db_id={db_id} honor={honor} account={account}")

        if account != "1":
            failures.append("the player is not logged in")

    errors, _ = server_errors(log_length)

    for failure in failures:
        print(f"FAIL: {failure}")

    if errors:
        print(f"\nFAIL: {len(errors)} server error(s) during the walk")

        for line in errors[:10]:
            print(f"  {line}")

        return 1

    if failures:
        return 1

    print(f"\nlogged in, no server errors, screenshots in {out}")

    if not args.keep_client:
        stop_client()

    return 0


if __name__ == "__main__":
    sys.exit(main())
