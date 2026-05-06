#!/bin/bash

# Instalacja / aktualizacja workflow Klaudiusz + Sokół w projekcie
# Użycie:
#   bash install.sh /ścieżka/do/projektu           — instalacja (nie nadpisuje)
#   bash install.sh /ścieżka/do/projektu --force    — aktualizacja (podmienia starą wersję)
#
# UWAGA: Ten skrypt musi być uruchamiany z lokalnego klonu repo.
# Nie działa z 'curl | bash' — potrzebuje plików źródłowych.

set -euo pipefail

PROJECT_DIR="${1:-.}"
FORCE=false
for arg in "$@"; do
    [ "$arg" = "--force" ] && FORCE=true
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Popek Agent Workflow ==="
if $FORCE; then
    echo "Tryb: AKTUALIZACJA (--force)"
else
    echo "Tryb: INSTALACJA"
fi
echo "Projekt: $(realpath "$PROJECT_DIR")"
echo ""

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Błąd: Katalog $PROJECT_DIR nie istnieje"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/klaudiusz.md" ] || [ ! -f "$SCRIPT_DIR/sokol.md" ]; then
    echo "Błąd: Nie znaleziono plików źródłowych workflow."
    echo "Ten skrypt musi być uruchamiany z lokalnego klonu repo:"
    echo "  git clone https://github.com/popek1990/popek-agent-workflow.git"
    echo "  bash popek-agent-workflow/install.sh $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# Funkcja: usuń starą sekcję workflow z pliku i wklej nową
update_file() {
    local file="$1"
    local marker="$2"
    local content="$3"
    local label="$4"

    # Znajdź linię z markerem
    local marker_line
    marker_line=$(grep -n "$marker" "$file" | head -1 | cut -d: -f1)

    if [ -z "$marker_line" ]; then
        printf "\n\n%s" "$content" >> "$file"
        echo "[OK] Dodano instrukcje workflow do $label"
        return
    fi

    # Cofnij się o 1-3 linie żeby złapać nagłówek sekcji (# Instrukcje dla...)
    local start=$marker_line
    for i in 1 2 3; do
        local check=$((marker_line - i))
        if [ $check -ge 1 ]; then
            local line
            line=$(sed -n "${check}p" "$file")
            if echo "$line" | grep -q "^# Instrukcje dla"; then
                start=$check
                break
            fi
        fi
    done

    # Zachowaj wszystko PRZED sekcją workflow, usuń pustę linie na końcu
    head -n $((start - 1)) "$file" | sed -e :a -e '/^\n*$/{$d;N;ba}' > "${file}.tmp"
    printf "\n\n%s" "$content" >> "${file}.tmp"
    mv "${file}.tmp" "$file"
    echo "[OK] Zaktualizowano instrukcje workflow w $label"
}

# --- CLAUDE.md ---
CLAUDE_MARKER="## Twoja rola"
CLAUDE_CONTENT="$(cat "$SCRIPT_DIR/klaudiusz.md")"

if [ -f "CLAUDE.md" ]; then
    if grep -qF "$CLAUDE_MARKER" "CLAUDE.md"; then
        if $FORCE; then
            update_file "CLAUDE.md" "$CLAUDE_MARKER" "$CLAUDE_CONTENT" "CLAUDE.md"
        else
            echo "[SKIP] CLAUDE.md już zawiera instrukcje workflow (użyj --force żeby zaktualizować)"
        fi
    else
        printf "\n\n%s" "$CLAUDE_CONTENT" >> "CLAUDE.md"
        echo "[OK] Dodano instrukcje workflow do CLAUDE.md"
    fi
else
    echo "$CLAUDE_CONTENT" > "CLAUDE.md"
    echo "[OK] Utworzono CLAUDE.md"
fi

# --- GEMINI.md ---
GEMINI_MARKER="## Twoja rola"
GEMINI_CONTENT="$(cat "$SCRIPT_DIR/sokol.md")"

if [ -f "GEMINI.md" ]; then
    if grep -qF "$GEMINI_MARKER" "GEMINI.md"; then
        if $FORCE; then
            update_file "GEMINI.md" "$GEMINI_MARKER" "$GEMINI_CONTENT" "GEMINI.md"
        else
            echo "[SKIP] GEMINI.md już zawiera instrukcje workflow (użyj --force żeby zaktualizować)"
        fi
    else
        printf "\n\n" >> "GEMINI.md"
        cat "$SCRIPT_DIR/sokol.md" >> "GEMINI.md"
        echo "[OK] Dodano instrukcje workflow do GEMINI.md"
    fi
else
    cp "$SCRIPT_DIR/sokol.md" "GEMINI.md"
    echo "[OK] Utworzono GEMINI.md"
fi

# --- Szablon planu ---
mkdir -p templates

if [ ! -f "templates/plan_template.md" ] || $FORCE; then
    cp "$SCRIPT_DIR/templates/plan_template.md" "templates/plan_template.md"
    echo "[OK] Skopiowano szablon planu do templates/"
else
    echo "[SKIP] Szablon planu już istnieje"
fi

echo ""
echo "=== Gotowe! ==="
