#!/usr/bin/env bash

# Build nvim.wasm

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTDIR="$ROOT/build-wasm"

source "$ROOT/.emsdk/emsdk_env.sh"

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

zig build nvim_bin \
  -Dtarget=wasm32-emscripten \
  -Dcpu=generic+atomics+bulk_memory+mutable_globals \
  -Demscripten-sysroot="$EMSDK/upstream/emscripten/cache/sysroot" \
  -Doptimize=ReleaseSmall

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
