# Testing

Everything needed to compile the plugins and run them against a real database
and a real game client. Two things live here:

1. a **docker environment** - MariaDB seeded with the pre-rework schema, an
   `amxxpc` compiler, and a Counter-Strike 1.6 server with Metamod and AMX Mod X
2. **scripts** that use it - a SQL checker and a client driver

All commands below are run from the repository root.

## Docker environment

| Service    | What it does |
|------------|--------------|
| `db`       | MariaDB 10.11, seeded from `sql/` with the pre-rework schema and a few rows |
| `compiler` | One-shot `amxxpc` run, writes `../compiled` |
| `server`   | HLDS + Metamod + AMX Mod X, loads the compiled plugins and connects to `db` |

MariaDB rather than MySQL 8, because the MySQL client bundled with AMX Mod X
cannot speak `caching_sha2_password`.

`plugins/cod_test_drive.sma` is loaded by this server only. It lets rcon push
client commands into a player, which has no business on a real server - keep it
out of `plugins-cod.ini`.

### Compile

```sh
docker compose -f testing/docker-compose.yml run --rm --user "$(id -u):$(id -g)" compiler
```

Pass file names to compile a subset:

```sh
docker compose -f testing/docker-compose.yml run --rm --user "$(id -u):$(id -g)" compiler cod_database.sma
```

Seven plugins (`shopsms/*` and `coditem_elektromagnes`) fail in `amxxpc`'s
packing step with `std::bad_alloc`. That is pre-existing and unrelated to the
mod code - their `.amx` output is still produced.

### Run the server

```sh
docker compose -f testing/docker-compose.yml up -d server
docker compose -f testing/docker-compose.yml logs -f server
```

The migration run is printed on startup:

```
[CoD Database] Migrated: 2026_08_08_000001_rename_legacy_tables
...
[CoD Database] Applied 14 migration(s) in batch 1.
```

A second start prints `Nothing to migrate.`

### Inspect the database

```sh
docker compose -f testing/docker-compose.yml exec db mysql -ucodmod -pcodmod codmod -e 'SELECT * FROM cod_migrations;'
```

MariaDB is also published on `127.0.0.1:13306`.

### Start over

```sh
docker compose -f testing/docker-compose.yml down -v
```

Dropping the volume replays the seed and the full migration run from scratch.

## validate-queries.py

The plugins build SQL with `formatex()`, so a wrong column name or a buffer that
is too small only surfaces when a player happens to trigger that code path -
which is how a truncated clan query survived review. This pulls every statement
out of the sources, fills the format specifiers and runs each one inside a
transaction that is rolled back, so nothing is written:

```sh
docker compose -f testing/docker-compose.yml up -d db
python3 testing/validate-queries.py
```

```
68/68 queries execute cleanly
```

Worth running after touching any query, and after any migration that renames a
column.

## drive-client.py

Launches Counter-Strike 1.6, connects it to the test server, logs the account
in, walks every menu and screenshots each step:

```sh
python3 testing/drive-client.py [--out DIR] [--keep-client]
```

```
restarting server
launching client
player 1 'Zolnierz' db_id=3 honor=13000 account=0
  01 account-login    01-account-login.png
  ...
after: 'Zolnierz' db_id=3 honor=13000 account=1

logged in, no server errors, screenshots in /tmp/codmod-shots-xxxx
```

It fails if the player never joins, if the login did not take, or if the server
logged an SQL error during the walk.

Requirements: the game installed through Steam (`HALF_LIFE_DIR` overrides the
path), Steam running and logged in, plus `wmctrl`, `xdotool` and ImageMagick.

### How it drives the client

Mostly from the server. `cod_test_drive` exposes `cod_drive <id> <command>` over
rcon, which pushes a client command into the connected player - menus have
client commands, items are picked with `menuselect`, `cancelselect` closes a
menu, and the login prompt is a client command that takes the password.

Two things need real input, because they are client side only:

- **the team and class panels**, which are VGUI. While a VGUI panel is open the
  client routes `menuselect` to it instead of to the plugin menu behind it, so
  the only way through is the number keys a player would press.
- **closing a MOTD**, whose OK button sends nothing to the server.

Both are done defensively. Keys are restricted to digits and are only sent while
X reports the game window focused. The pointer is positioned relative to the
window and the click only happens once X confirms the window under it is the
game, after which the pointer is put back. No text is ever typed, so nothing can
leak into another window.

### Things worth knowing

- Each run restarts the server. A client killed without disconnecting leaves its
  slot occupied and the next connection hangs on "Establishing network
  connection".
- The server's own MOTD is emptied by the entrypoint. The panel a player gets on
  connect stays open until it is clicked away, and while it is open every MOTD a
  plugin sends afterwards is dropped - which is exactly what the top15 listings
  use.
- Every step that opens a MOTD closes it again right after the screenshot, and
  the close is verified by comparing the screen before and after. A MOTD left
  open covers everything behind it.
- `xdotool getwindowgeometry` counts the frame decoration twice for this window,
  so root coordinates land about 30px low. The driver positions the pointer
  relative to the window instead.

### Skipping the in-game download

Copy the mod resources into the client once, otherwise every fresh connect
downloads them:

```sh
CS=~/.local/share/Steam/steamapps/common/Half-Life/cstrike
cp -r resources/models/. $CS/models/
cp -r resources/sound/. $CS/sound/
cp -r resources/sprites/. $CS/sprites/
```

## Connecting by hand

The server listens on `27015` with `sv_lan 1`, so a client can connect to
`127.0.0.1:27015` directly. The seeded accounts are `Zolnierz`, `Kapral` and
`Sierzant`, with passwords `secret1` to `secret3`.
