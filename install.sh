#!/bin/bash

# Instalacja workflow Klaudiusz + Sokół w projekcie
# Użycie: bash install.sh [ścieżka_do_projektu]
#
# UWAGA: Ten skrypt musi być uruchamiany z lokalnego klonu repo.
# Nie działa z 'curl | bash' — potrzebuje plików źródłowych.

set -euo pipefail

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Instalacja Popek Agent Workflow ==="
echo "Projekt: $(realpath "$PROJECT_DIR")"
echo ""

# Sprawdź czy katalog istnieje
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Błąd: Katalog $PROJECT_DIR nie istnieje"
    exit 1
fi

# Sprawdź czy pliki źródłowe są dostępne
if [ ! -f "$SCRIPT_DIR/klaudiusz.md" ] || [ ! -f "$SCRIPT_DIR/sokol.md" ]; then
    echo "Błąd: Nie znaleziono plików źródłowych workflow."
    echo "Ten skrypt musi być uruchamiany z lokalnego klonu repo:"
    echo "  git clone https://github.com/popek1990/popek-agent-workflow.git"
    echo "  bash popek-agent-workflow/install.sh $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# --- CLAUDE.md (pełne instrukcje dla Klaudiusza) ---
CLAUDE_MARKER="## Twoja rola"
CLAUDE_CONTENT="$(cat "$SCRIPT_DIR/klaudiusz.md")"

if [ -f "CLAUDE.md" ]; then
    if grep -qF "$CLAUDE_MARKER" "CLAUDE.md"; then
        echo "[SKIP] CLAUDE.md już zawiera instrukcje workflow"
    else
        printf "\n\n%s" "$CLAUDE_CONTENT" >> "CLAUDE.md"
        echo "[OK] Dodano pełne instrukcje workflow do CLAUDE.md"
    fi
else
    echo "$CLAUDE_CONTENT" > "CLAUDE.md"
    echo "[OK] Utworzono CLAUDE.md z pełnymi instrukcjami workflow"
fi

# --- GEMINI.md (pełne instrukcje dla Sokoła) ---
GEMINI_MARKER="## Twoja rola"

if [ ! -f "GEMINI.md" ]; then
    cp "$SCRIPT_DIR/sokol.md" "GEMINI.md"
    echo "[OK] Utworzono GEMINI.md (instrukcje dla Sokoła)"
else
    if grep -qF "$GEMINI_MARKER" "GEMINI.md"; then
        echo "[SKIP] GEMINI.md już zawiera instrukcje workflow"
    else
        printf "\n\n" >> "GEMINI.md"
        cat "$SCRIPT_DIR/sokol.md" >> "GEMINI.md"
        echo "[OK] Dodano instrukcje workflow do GEMINI.md"
    fi
fi

# --- Szablon planu ---
mkdir -p templates

if [ ! -f "templates/plan_template.md" ]; then
    cp "$SCRIPT_DIR/templates/plan_template.md" "templates/plan_template.md"
    echo "[OK] Skopiowano szablon planu do templates/"
else
    echo "[SKIP] Szablon planu już istnieje"
fi

echo ""
echo "=== Gotowe! ==="
echo ""
echo "Co zainstalowano:"
echo "  - CLAUDE.md    ← pełne instrukcje dla Klaudiusza"
echo "  - GEMINI.md    ← pełne instrukcje dla Sokoła"
echo "  - templates/   ← szablon planu wdrożenia"
echo ""
echo "Następne kroki:"
echo "  1. Otwórz terminal z Claude Code → Klaudiusz gotowy"
echo "  2. Otwórz terminal z Gemini/Codex → Sokół gotowy"
echo "  3. Zacznij od Sokoła — niech znajdzie coś do poprawy"
