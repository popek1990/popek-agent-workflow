#!/bin/bash

# Instalacja workflow Klaudiusz + Sokół w projekcie
# Użycie: bash install.sh [ścieżka_do_projektu]

set -e

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Instalacja Popek Agent Workflow ==="
echo "Projekt: $PROJECT_DIR"
echo ""

# Sprawdź czy katalog istnieje
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Błąd: Katalog $PROJECT_DIR nie istnieje"
    exit 1
fi

cd "$PROJECT_DIR"

# --- CLAUDE.md (dla Klaudiusza) ---
CLAUDE_SECTION="
# Agent Workflow: Klaudiusz + Sokół

## Rola
Jesteś **Klaudiusz** — główny agent deweloperski w dual-agent workflow.
Pracujesz w parze z **Sokołem** (Gemini/Codex), koordynuje Was Orkiestrator (człowiek).

## Zasady
- NIGDY nie ruszaj kodu bez zielonego światła od Orkiestratora
- Gdy dostajesz prompt od Sokoła — twórz plan (plan_*.md), nie implementuj
- Prompty dla Sokoła pisz po polsku i wypisuj w terminalu
- Pod każdą odpowiedzią dodaj sekcję prostym językiem dla Orkiestratora
- Po zatwierdzeniu planu: senior-architect → wdrożenie → code-review → push

## Format odpowiedzi
Na końcu każdej odpowiedzi:
---
**Dla Orkiestratora:** [wyjaśnienie prostym językiem — co, jak, dlaczego, ryzyka]
"

if [ -f "CLAUDE.md" ]; then
    if grep -q "Klaudiusz" "CLAUDE.md"; then
        echo "[SKIP] CLAUDE.md już zawiera instrukcje workflow"
    else
        echo "" >> "CLAUDE.md"
        echo "$CLAUDE_SECTION" >> "CLAUDE.md"
        echo "[OK] Dodano instrukcje workflow do CLAUDE.md"
    fi
else
    echo "$CLAUDE_SECTION" > "CLAUDE.md"
    echo "[OK] Utworzono CLAUDE.md z instrukcjami workflow"
fi

# --- GEMINI.md (dla Sokoła) ---
if [ ! -f "GEMINI.md" ]; then
    cp "$SCRIPT_DIR/sokol.md" "GEMINI.md"
    echo "[OK] Utworzono GEMINI.md (instrukcje dla Sokoła)"
else
    if grep -q "Sokół" "GEMINI.md"; then
        echo "[SKIP] GEMINI.md już zawiera instrukcje workflow"
    else
        echo "" >> "GEMINI.md"
        cat "$SCRIPT_DIR/sokol.md" >> "GEMINI.md"
        echo "[OK] Dodano instrukcje workflow do GEMINI.md"
    fi
fi

# --- Szablon planu ---
if [ ! -d "templates" ]; then
    mkdir -p templates
fi

if [ ! -f "templates/plan_template.md" ]; then
    cp "$SCRIPT_DIR/templates/plan_template.md" "templates/plan_template.md"
    echo "[OK] Skopiowano szablon planu do templates/"
else
    echo "[SKIP] Szablon planu już istnieje"
fi

echo ""
echo "=== Gotowe! ==="
echo ""
echo "Następne kroki:"
echo "  1. Otwórz terminal z Claude Code → Klaudiusz gotowy"
echo "  2. Otwórz terminal z Gemini/Codex → Sokół gotowy"
echo "  3. Zacznij od Sokoła — niech znajdzie coś do poprawy"
