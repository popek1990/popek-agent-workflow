#!/bin/bash
# Extract clean digests from raw session logs
# Usage: bash extract-logs.sh [project-dir]
#   Processes all raw logs that don't have a digest yet.

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RAW_DIR="$PROJECT_DIR/logs/workflow/raw"
DIGEST_DIR="$PROJECT_DIR/logs/workflow/digest"
mkdir -p "$DIGEST_DIR"

if [ ! -d "$RAW_DIR" ]; then
    echo "No raw logs found in $RAW_DIR"
    exit 1
fi

count=0

for raw_file in "$RAW_DIR"/*.script; do
    [ -f "$raw_file" ] || continue
    base=$(basename "$raw_file" .script)
    digest="$DIGEST_DIR/${base}.md"
    [ -f "$digest" ] && continue
    echo "Extracting: $base"
    python3 "$SCRIPT_DIR/extract_gemini.py" "$raw_file" "$digest"
    count=$((count + 1))
done

for meta_file in "$RAW_DIR"/*.meta; do
    [ -f "$meta_file" ] || continue
    base=$(basename "$meta_file" .meta)
    digest="$DIGEST_DIR/${base}.md"
    [ -f "$digest" ] && continue
    echo "Extracting: $base"
    python3 "$SCRIPT_DIR/extract_claude.py" "$meta_file" "$digest"
    count=$((count + 1))
done

# Also check Gemini native JSONL (for sessions without sokol-log.sh wrapper)
PROJECT_NAME=$(basename "$(realpath "$PROJECT_DIR")")
GEMINI_CHATS="$HOME/.gemini/tmp/$PROJECT_NAME/chats"
if [ -d "$GEMINI_CHATS" ]; then
    for jsonl in "$GEMINI_CHATS"/*.jsonl; do
        [ -f "$jsonl" ] || continue
        base=$(basename "$jsonl" .jsonl)
        digest="$DIGEST_DIR/sokol_${base}.md"
        [ -f "$digest" ] && continue
        echo "Extracting (gemini native): $base"
        python3 "$SCRIPT_DIR/extract_gemini.py" "$jsonl" "$digest"
        count=$((count + 1))
    done
fi

if [ $count -eq 0 ]; then
    echo "No new logs to extract."
else
    echo "Extracted $count digest(s) to $DIGEST_DIR/"
fi
