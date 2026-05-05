#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_DIR="$ROOT_DIR/LocalFashionAI"
VENV_DIR="$AI_DIR/.venv"

if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi

"$VENV_DIR/bin/python" -m pip install --upgrade pip
"$VENV_DIR/bin/python" -m pip install -r "$AI_DIR/requirements.txt"

cd "$AI_DIR"
exec "$VENV_DIR/bin/uvicorn" app.main:app --host 127.0.0.1 --port 8000 --reload
