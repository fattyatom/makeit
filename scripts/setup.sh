#!/bin/bash
# Install everything the pipeline needs: OpenSCAD (+ xvfb for headless
# previews) and the Python deps. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

missing=()
command -v openscad >/dev/null || missing+=(openscad)
command -v xvfb-run >/dev/null || missing+=(xvfb)
if [ ${#missing[@]} -gt 0 ]; then
  SUDO=""
  [ "$(id -u)" -ne 0 ] && SUDO="sudo"
  $SUDO apt-get update -qq || true
  DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y -qq "${missing[@]}"
fi

python3 -m pip install -q -r requirements.txt 2>/dev/null \
  || python3 -m pip install -q --break-system-packages -r requirements.txt
