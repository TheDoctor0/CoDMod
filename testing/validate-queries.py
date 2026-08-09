#!/usr/bin/env python3
"""Runs every SQL statement in the plugins against the test database.

The plugins build their queries with formatex(), so a mistyped column or a
buffer that is too small only shows up when a player happens to trigger that
code path. This pulls the literals straight out of the sources, fills the
format specifiers with sample values, and executes each one inside a
transaction that is rolled back, so nothing is written.

Usage: docker compose up -d db && python3 testing/validate-queries.py
"""

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCES = ["cod_mod.sma", "cod_stats.sma", "cod_clans.sma", "cod_missions.sma", "cod_database.sma"]
CONTAINER = "codmod-db-1"

STATEMENT = re.compile(r"\s*(SELECT|INSERT|UPDATE|DELETE)", re.I)
CALLS = [r"formatex\((?:queryData|tempData)[^;]*?;", r"run_query\(\"(?:[^\"]*)\"\)"]

# A literal that is nothing but a backticked identifier is a column name picked
# at runtime, not part of the format string.
COLUMN_ARGUMENT = re.compile(r"^`\w+`$")


def extract(path):
    src = path.read_text().replace("\\\n", "")
    src = src.replace('^"', "\x01")  # Pawn's escaped double quote

    for pattern in CALLS:
        for match in re.finditer(pattern, src, re.S):
            parts = re.findall(r'"([^"]*)"', match.group(0))
            columns = [p for p in parts if COLUMN_ARGUMENT.match(p)]
            literal = "".join(p for p in parts if not COLUMN_ARGUMENT.match(p))

            if not STATEMENT.match(literal):
                continue

            yield normalise(literal.replace("\x01", '"'), columns)


def normalise(query, columns):
    query = re.sub(r"\s+", " ", query).strip()

    for column in columns:
        query = query.replace("%s", column, 1)

    query = re.sub(r"%[0-9]*[idf]", "1", query)
    query = query.replace("%s%s", "")  # optional SET fragments
    query = query.replace("%s", "Zolnierz")

    return query


def run(query):
    result = subprocess.run(
        ["docker", "exec", "-i", CONTAINER, "mysql", "-ucodmod", "-pcodmod", "codmod"],
        input=f"START TRANSACTION;\n{query.rstrip(';')};\nROLLBACK;",
        capture_output=True,
        text=True,
    )

    return [line for line in result.stderr.split("\n") if "ERROR" in line]


def main():
    failures = []
    total = 0

    for name in SOURCES:
        for query in extract(ROOT / name):
            total += 1
            errors = run(query)

            if errors:
                failures.append((name, query, errors[0]))

    print(f"{total - len(failures)}/{total} queries execute cleanly")

    for name, query, error in failures:
        print(f"\n{name}\n  {query[:200]}\n  {error[:200]}")

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
