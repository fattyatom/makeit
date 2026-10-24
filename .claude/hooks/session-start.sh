#!/bin/bash
# Claude Code cloud sessions only: install OpenSCAD + Python deps.
set -euo pipefail
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi
"${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}/scripts/setup.sh"
