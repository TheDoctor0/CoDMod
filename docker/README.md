# Docker test environment

Compiles the plugins and runs them on a real Counter-Strike 1.6 server against a
real database, which is the only way to see the migrations actually execute.

Three services:

| Service    | What it does |
|------------|--------------|
| `db`       | MariaDB 10.11, seeded from `sql/` with the pre-rework schema and a few rows |
| `compiler` | One-shot `amxxpc` run, writes `../compiled` |
| `server`   | HLDS + Metamod + AMX Mod X, loads the compiled plugins and connects to `db` |

`plugins/cod_test_drive.sma` is loaded by this server only. It lets rcon push
client commands into a player, which is exactly the kind of thing that has no
business on a real server - keep it out of `plugins-cod.ini`.

MariaDB rather than MySQL 8, because the MySQL client bundled with AMX Mod X
cannot speak `caching_sha2_password`.

## Compile

```sh
docker compose run --rm --user "$(id -u):$(id -g)" compiler
```

Add file names to compile a subset:

```sh
docker compose run --rm --user "$(id -u):$(id -g)" compiler cod_database.sma cod_mod.sma
```

Seven plugins (`shopsms/*` and `coditem_elektromagnes`) fail in `amxxpc`'s
packing step with `std::bad_alloc`. That is pre-existing and unrelated to the
mod code - their `.amx` output is still produced.

## Run

```sh
docker compose up -d server
docker compose logs -f server
```

The migration run is printed on startup:

```
[CoD Database] Migrated: 2026_08_08_000001_rename_legacy_tables
...
[CoD Database] Applied 14 migration(s) in batch 1.
```

A second start prints `Nothing to migrate.`

## Validate the queries

The plugins build SQL with `formatex()`, so a wrong column name or an undersized
buffer only surfaces when a player triggers that exact code path. This pulls
every statement out of the sources and runs it against the database inside a
transaction that is rolled back:

```sh
docker compose up -d db
python3 validate-queries.py
```

```
68/68 queries execute cleanly
```

Worth running after touching any query, and after adding a migration that
changes a column name.

## Drive a real client through the menus

`drive-client.py` launches Counter-Strike 1.6, connects it to the test server,
logs the account in and walks every menu, screenshotting each step:

```sh
python3 docker/drive-client.py [--out DIR] [--keep-client]
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

How it works: the `cod_test_drive` plugin exposes `cod_drive <id> <command>`
over rcon, which pushes a client command into the connected player. That is
enough for everything - menus are opened by their normal client commands, items
are picked with `menuselect`, `cancelselect` closes a menu, and the login
prompts are ordinary client commands. Nothing is typed into the desktop, so a
stray keystroke can never land in another window; the only thing done on the X
server is capturing the game window.

Requirements: the game installed through Steam (`HALF_LIFE_DIR` overrides the
path), Steam running and logged in, plus `wmctrl` and ImageMagick.

Two things worth knowing:

- Each run restarts the server. A client killed without disconnecting leaves its
  slot occupied and the next connection hangs on "Establishing network
  connection", so a clean server is the reliable starting point.
- The MOTD panel a player gets on connect stays open and swallows the top15
  listings, so those steps show the menu behind it rather than the MOTD. The
  queries behind them are covered by `validate-queries.py`.

Copy the mod resources into the client once to skip the in-game download:

```sh
CS=~/.local/share/Steam/steamapps/common/Half-Life/cstrike
cp -r resources/models/. $CS/models/
cp -r resources/sound/. $CS/sound/
cp -r resources/sprites/. $CS/sprites/
```

## Inspect the database

```sh
docker compose exec db mysql -ucodmod -pcodmod codmod -e 'SELECT * FROM cod_migrations;'
```

MariaDB is also published on `127.0.0.1:13306`.

## Start over

```sh
docker compose down -v
```

This drops the volume, so the next start replays the seed and the full migration
run from scratch.

## Connect a client by hand

The server listens on `27015` with `sv_lan 1`, so a Counter-Strike 1.6 client
can connect to `127.0.0.1:27015` directly. The seeded accounts are `Zolnierz`,
`Kapral` and `Sierzant` with passwords `secret1` to `secret3`.
