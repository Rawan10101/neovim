#!/usr/bin/env bash

# Build nvim.wasm

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTDIR="$ROOT/build-wasm"

mkdir -p "$OUTDIR"

if ! command -v emcc >/dev/null 2>&1; then
  echo "ERROR: emcc not found"
  exit 1
fi

if ! command -v zig >/dev/null 2>&1; then
  echo "ERROR: zig not found"
  exit 1
fi

emcc --version
zig version

if [ -z "${CUSTOM_BUILD_CMD:-}" ]; then
  echo "ERROR: CUSTOM_BUILD_CMD is not set"
  exit 1
fi

eval "$CUSTOM_BUILD_CMD"

ZIG_OUT="$ROOT/zig-out/bin"

required=(
  nvim.wasm
  nvim.js
  nvim.data
)

missing=()

for name in "${required[@]}"; do
  if [ -f "$ZIG_OUT/$name" ]; then
    cp "$ZIG_OUT/$name" "$OUTDIR/$name"
  else
    missing+=("$name")
  fi
done

if [ "${#missing[@]}" -ne 0 ]; then
  echo "ERROR: Missing required WASM artifacts: ${missing[*]}"
  ls -la "$ZIG_OUT" || true
  exit 2
fi

echo "build-wasm.sh finished successfully."
