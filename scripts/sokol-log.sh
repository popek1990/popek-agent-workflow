#!/bin/bash
# Wrapper for Gemini CLI that captures full terminal output
# Usage: bash sokol-log.sh [project-dir]
#   project-dir: path to target project (default: current directory)

PROJECT_DIR="${1:-.}"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
SESSION_ID=$(head -c 4 /dev/urandom | xxd -p)
LOG_DIR="$PROJECT_DIR/logs/workflow/raw"
mkdir -p "$LOG_DIR"

LOGFILE="$LOG_DIR/sokol_${TIMESTAMP}_${SESSION_ID}.script"

echo "━━━ Sokół session logging ━━━"
echo "Log: $LOGFILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$PROJECT_DIR" && script -f -q "$LOGFILE" -c "gemini"
