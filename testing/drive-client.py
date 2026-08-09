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
    python3 testing/drive-client.py [--out DIR] [--keep-client]
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

# Each action is one of:
#   cmd:<client command>  stuffed into the player from the server
#   srv:<server command>   run on the server, {id} is the player index
#   key:<digit>            keypress, only while the game window has focus
#   ok                     click the MOTD OK button
#
# Keys are needed for the team and class panels: while a VGUI panel is open the
# client routes menuselect to it rather than to the plugin menu behind it, so
# the only way through is the number keys a player would press.
#
# The fourth field runs straight after the screenshot. Anything that opens a
# MOTD closes it again there: a MOTD left open covers the screen and swallows
# every MOTD sent after it.
STEPS = [
    ("account-login", [f"cmd:WPROWADZ_SWOJE_HASLO {PLAYER_PASSWORD}"], 2.0, []),
    ("team-select", ["key:1"], 2.0, []),
    ("faction-select", ["key:1"], 2.0, []),
    ("class-select", ["key:1"], 2.5, []),
    ("class-menu", ["cmd:klasa"], 1.5, ["cmd:cancelselect"]),
    ("classes-motd", ["cmd:klasy"], 2.5, ["ok"]),
    ("level-top15", ["cmd:top"], 3.5, ["ok"]),
    ("knife-menu", ["cmd:noze"], 1.5, ["cmd:cancelselect"]),
    ("hud-menu", ["cmd:hud"], 1.5, ["cmd:cancelselect"]),
    ("mission-menu", ["cmd:misje"], 1.5, ["cmd:cancelselect"]),
    ("exchange-menu", ["cmd:wymien"], 1.5, ["cmd:cancelselect"]),
    ("clan-menu", ["cmd:klan"], 2.5, []),
    ("clan-members", ["cmd:menuselect 1"], 3.0, ["cmd:cancelselect"]),
    ("clan-top15", ["cmd:klan", "cmd:menuselect 6"], 3.5, ["ok"]),
    ("stats-menu", ["cmd:menustaty"], 1.5, ["cmd:cancelselect"]),
    ("time-top15", ["cmd:topczas"], 3.5, ["ok"]),
    ("stats-top15", ["cmd:topstaty"], 3.5, ["ok"]),
    ("medals-top15", ["cmd:medale"], 3.5, ["ok"]),
    ("free-honor", ["cmd:freehonor"], 2.0, ["cmd:cancelselect"]),
]

# MOTD "OK" button, relative to the 1280x720 game window
OK_BUTTON = (370, 561)

WHO = re.compile(r"id=(\d+) name=(.+?) db_id=(\d+) honor=(-?\d+) account=(\d+)")


def sh(*command, check=False):
    return subprocess.run(command, capture_output=True, text=True, check=check).stdout


ALLOWED_KEYS = set("0123456789")


def pointer():
    values = {}

    for line in sh("xdotool", "getmouselocation", "--shell").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            values[key] = value

    return values


def key_in_game(key):
    """Sends one key, and only while X reports the game window focused.

    Digits only, so even a press that somehow lands elsewhere cannot enter text.
    """
    if key not in ALLOWED_KEYS:
        raise ValueError(f"key {key} is not allowed")

    window = game_window()

    if not window:
        return False

    subprocess.run(["wmctrl", "-ia", window], check=False)
    time.sleep(0.6)

    if sh("xdotool", "getwindowfocus").strip() != str(int(window, 16)):
        print(f"       game window is not focused, skipping key {key}")

        return False

    subprocess.run(["xdotool", "key", "--clearmodifiers", key], check=False)
    time.sleep(0.5)

    return True


def click_in_game(rel_x, rel_y):
    """Clicks inside the game window, and only there.

    The pointer is placed relative to the window rather than in root
    coordinates, because xdotool's getwindowgeometry counts the frame
    decoration twice and every click then lands ~30px low. The click only
    happens once X confirms the window under the pointer is the game, and the
    pointer goes back where it was afterwards.
    """
    window = game_window()

    if not window:
        return False

    subprocess.run(["wmctrl", "-ia", window], check=False)
    time.sleep(0.5)

    before = pointer()

    subprocess.run(
        ["xdotool", "mousemove", "--window", window, str(rel_x), str(rel_y)], check=False
    )
    time.sleep(0.3)

    on_target = pointer().get("WINDOW") == str(int(window, 16))

    if on_target:
        subprocess.run(["xdotool", "click", "1"], check=False)
        time.sleep(0.4)
    else:
        print("       pointer is not over the game, skipping click")

    subprocess.run(["xdotool", "mousemove", before["X"], before["Y"]], check=False)

    return on_target


def close_motd(window, out):
    """Clicks OK and checks the screen actually changed, because a MOTD left
    open covers everything and swallows the next one."""
    for attempt in range(2):
        before = out / ".motd-before.png"
        after = out / ".motd-after.png"

        subprocess.run(["import", "-window", window, str(before)], check=False)
        click_in_game(*OK_BUTTON)
        time.sleep(1.0)
        subprocess.run(["import", "-window", window, str(after)], check=False)

        difference = subprocess.run(
            ["compare", "-metric", "AE", str(before), str(after), "null:"],
            capture_output=True,
            text=True,
        ).stderr.strip()

        before.unlink(missing_ok=True)
        after.unlink(missing_ok=True)

        if difference and difference.isdigit() and int(difference) > 10000:
            return True

    print("       MOTD did not close")

    return False


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

    def run(actions):
        for action in actions:
            if action == "ok":
                close_motd(game_window(), out)
            elif action.startswith("key:"):
                key_in_game(action[4:])
            elif action.startswith("srv:"):
                rcon.command(action[4:].replace("{id}", player_id))
            else:
                rcon.command(f"cod_drive {player_id} {action[4:]}")

            time.sleep(0.4)

    # a MOTD left over from an earlier run would cover the first screenshots
    click_in_game(*OK_BUTTON)

    for index, (label, before, settle, after) in enumerate(STEPS, start=1):
        run(before)

        time.sleep(settle)

        window = game_window() or window
        path = screenshot(window, out, label, index)

        # never leave a MOTD or menu sitting on the screen
        run(after)

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
