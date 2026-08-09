#!/bin/bash
# Installs the freshly compiled CoD Mod plugins into the server and starts HLDS.
set -euo pipefail

CSTRIKE_DIR=${CSTRIKE_DIR:-/home/steam/hlds/cstrike}
AMXX_DIR="$CSTRIKE_DIR/addons/amxmodx"
SRC=${SRC:-/src}

SQL_HOST=${COD_SQL_HOST:-db}
SQL_USER=${COD_SQL_USER:-codmod}
SQL_PASS=${COD_SQL_PASS:-codmod}
SQL_DB=${COD_SQL_DB:-codmod}

echo "[entrypoint] installing plugins"

cp -f "$SRC"/compiled/*.amxx "$AMXX_DIR/plugins/"

if [ -d "$SRC/resources" ]; then
	cp -rf "$SRC"/resources/. "$CSTRIKE_DIR/"
fi

cp -f /home/steam/config/plugins.ini "$AMXX_DIR/configs/plugins.ini"

cp -f /home/steam/config/server.cfg "$CSTRIKE_DIR/server.cfg"

# The MOTD panel a player gets on connect stays open until it is clicked away,
# and swallows every MOTD a plugin sends afterwards, which is exactly what the
# top15 listings use. An empty file means the panel never opens.
: > "$CSTRIKE_DIR/motd.txt"

# server.cfg is executed by the engine before the plugins reach plugin_cfg(),
# which is where the first connection attempt happens. amxx.cfg runs too late.
{
	echo ""
	echo "// injected by docker entrypoint"
	echo "cod_sql_host \"$SQL_HOST\""
	echo "cod_sql_user \"$SQL_USER\""
	echo "cod_sql_pass \"$SQL_PASS\""
	echo "cod_sql_db \"$SQL_DB\""
} >> "$CSTRIKE_DIR/server.cfg"

echo "[entrypoint] waiting for $SQL_HOST"

for _ in $(seq 1 60); do
	if (exec 3<>"/dev/tcp/$SQL_HOST/3306") 2>/dev/null; then
		break
	fi

	sleep 1
done

echo "[entrypoint] starting hlds"

cd /home/steam/hlds

export LD_LIBRARY_PATH="/home/steam/hlds:${LD_LIBRARY_PATH:-}"

exec ./hlds_linux -game cstrike -nomaster -insecure -pingboost 3 \
	+sv_lan 1 +maxplayers "${MAXPLAYERS:-12}" +map "${MAP:-de_dust2}"
