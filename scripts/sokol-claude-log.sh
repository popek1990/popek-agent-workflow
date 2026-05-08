#!/bin/bash
# Wrapper for Claude CLI used as Sokół, with session metadata for digest extraction.
# Usage: bash sokol-claude-log.sh [project-dir]
#   project-dir: path to target project (default: current directory)
#
# Claude CLI already saves full JSONL transcripts to ~/.claude/projects/.
# This wrapper just names the session and records metadata for extraction.

PROJECT_DIR="${1:-.}"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
SESSION_ID=$(head -c 4 /dev/urandom | xxd -p)
LOG_DIR="$PROJECT_DIR/logs/workflow/raw"
mkdir -p "$LOG_DIR"

META_FILE="$LOG_DIR/sokol-claude_${TIMESTAMP}_${SESSION_ID}.meta"
SESSION_NAME="sokol-claude-${TIMESTAMP}"

cat > "$META_FILE" << EOF
session_name: $SESSION_NAME
timestamp: $(date -Iseconds)
project_dir: $(realpath "$PROJECT_DIR")
EOF

echo "━━━ Sokół Claude session logging ━━━"
echo "Session: $SESSION_NAME"
echo "Meta: $META_FILE"
echo "Full JSONL: ~/.claude/projects/ (automatic)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$PROJECT_DIR" && claude --resume "$SESSION_NAME"
