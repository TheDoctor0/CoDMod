#!/bin/sh
# Compiles CoD Mod plugins with amxxpc.
#
# Usage: compile.sh [file.sma ...]
# With no arguments every .sma in the repository is compiled.
set -eu

SRC=${SRC:-/src}
OUT=${OUT:-/src/compiled}
AMXX_SCRIPTING=${AMXX_SCRIPTING:-/opt/amxmodx/addons/amxmodx/scripting}

mkdir -p "$OUT"

if [ "$#" -gt 0 ]; then
	set -- "$@"
else
	# shellcheck disable=SC2046 # word splitting is what we want here
	set -- $(cd "$SRC" && find . -name '*.sma' | sed 's|^\./||' | sort)
fi

failed=0

for plugin in "$@"; do
	name=$(basename "$plugin" .sma)

	printf '>>> %s\n' "$plugin"

	# amxxpc dlopen()s amxxpc32.so from the working directory, so run it from there.
	if (cd "$AMXX_SCRIPTING" && ./amxxpc \
		"-i$AMXX_SCRIPTING/include" \
		"-i$SRC" \
		"-o$OUT/$name.amxx" \
		"$SRC/$plugin"); then
		:
	else
		failed=$((failed + 1))
	fi
done

if [ "$failed" -ne 0 ]; then
	printf '\n%s plugin(s) failed to compile.\n' "$failed" >&2
	exit 1
fi

printf '\nAll plugins compiled into %s.\n' "$OUT"
