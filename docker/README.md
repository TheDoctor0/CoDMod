# Docker test environment

Compiles the plugins and runs them on a real Counter-Strike 1.6 server against a
real database, which is the only way to see the migrations actually execute.

Three services:

| Service    | What it does |
|------------|--------------|
| `db`       | MariaDB 10.11, seeded from `sql/` with the pre-rework schema and a few rows |
| `compiler` | One-shot `amxxpc` run, writes `../compiled` |
| `server`   | HLDS + Metamod + AMX Mod X, loads the compiled plugins and connects to `db` |

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

## Connect a client

The server listens on `27015` with `sv_lan 1`. Point a Counter-Strike 1.6 client
at `127.0.0.1:27015` to exercise the per-player paths (account login, class
loading, clans).
