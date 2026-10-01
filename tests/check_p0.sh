#!/usr/bin/env bash
# Linux helper. Pass the Godot 4.7.2 executable as the first argument.
set -euo pipefail
GODOT_BIN="${1:-godot}"
cd "$(dirname "$0")/.."
mkdir -p work/test-logs
run_check() {
  local name="$1"
  shift
  if ! timeout 60 "$GODOT_BIN" "$@" >"work/test-logs/$name.log" 2>&1; then
    cat "work/test-logs/$name.log"
    exit 1
  fi
  # Godot may exit 0 after some import/parser errors: gate the logs too.
  if grep -Eq 'SCRIPT ERROR|ERROR:|Parse Error' "work/test-logs/$name.log"; then
    cat "work/test-logs/$name.log"
    exit 1
  fi
  echo "$name: PASS"
}
"$GODOT_BIN" --version
run_check import --headless --path . --editor --import
run_check tests --headless --path . --script res://tests/run_tests.gd
cat work/test-logs/tests.log
run_check scene --headless --path . --quit-after 120
