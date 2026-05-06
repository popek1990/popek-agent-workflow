#!/bin/bash

# Instalacja / aktualizacja workflow Klaudiusz + Sokół w projekcie
# Użycie:
#   bash install.sh /ścieżka/do/projektu           — instalacja (nie nadpisuje)
#   bash install.sh /ścieżka/do/projektu --force    — aktualizacja (podmienia starą wersję)

set -euo pipefail

# --- Kolory i symbole ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

OK="✅"
SKIP="⏭️ "
FAIL="❌"
ROCKET="🚀"
GEAR="⚙️ "
FOLDER="📁"
FILE="📄"
LINK="🔗"
CHECK="✔️ "
WARN="⚠️ "

# --- Argumenty ---
PROJECT_DIR="${1:-.}"
FORCE=false
for arg in "$@"; do
    [ "$arg" = "--force" ] && FORCE=true
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Header ---
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║  ${ROCKET} Popek Agent Workflow                     ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

if $FORCE; then
    echo -e "  ${GEAR} Tryb:    ${YELLOW}AKTUALIZACJA${NC} (--force)"
else
    echo -e "  ${GEAR} Tryb:    ${GREEN}INSTALACJA${NC}"
fi
echo -e "  ${FOLDER} Projekt: ${BOLD}$(realpath "$PROJECT_DIR")${NC}"
echo ""
echo -e "${DIM}──────────────────────────────────────────────${NC}"

# --- Walidacja ---
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "\n  ${FAIL} ${RED}Katalog $PROJECT_DIR nie istnieje${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/klaudiusz.md" ] || [ ! -f "$SCRIPT_DIR/sokol.md" ]; then
    echo -e "\n  ${FAIL} ${RED}Nie znaleziono plików źródłowych workflow${NC}"
    echo -e "  ${DIM}Ten skrypt musi być uruchamiany z lokalnego klonu repo:${NC}"
    echo -e "  ${DIM}  git clone https://github.com/popek1990/popek-agent-workflow.git${NC}"
    echo -e "  ${DIM}  bash popek-agent-workflow/install.sh $PROJECT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

# --- Tryb --force: sprawdź czy workflow był wcześniej zainstalowany ---
if $FORCE; then
    MARKER="## Twoja rola"
    HAS_CLAUDE=false
    HAS_GEMINI=false
    [ -f "CLAUDE.md" ] && grep -qF "$MARKER" "CLAUDE.md" 2>/dev/null && HAS_CLAUDE=true
    [ -f "GEMINI.md" ] && grep -qF "$MARKER" "GEMINI.md" 2>/dev/null && HAS_GEMINI=true

    if ! $HAS_CLAUDE && ! $HAS_GEMINI; then
        echo -e "\n  ${SKIP}${YELLOW}Workflow nie był zainstalowany — pomijam${NC}"
        echo -e "  ${DIM}Użyj bez --force aby zainstalować po raz pierwszy${NC}\n"
        exit 0
    fi
fi

# Liczniki do podsumowania
INSTALLED=0
UPDATED=0
SKIPPED=0
FAILED=0
SMOKE_PASS=0
SMOKE_FAIL=0

inc() { eval "$1=\$(($1 + 1))"; }

log_ok()      { echo -e "  ${OK} ${GREEN}$1${NC}"; }
log_update()  { echo -e "  ${OK} ${BLUE}$1${NC}"; }
log_skip()    { echo -e "  ${SKIP}${YELLOW}$1${NC}"; }
log_fail()    { echo -e "  ${FAIL} ${RED}$1${NC}"; }

# --- Funkcja: podmień starą sekcję workflow na nową ---
update_file() {
    local file="$1"
    local marker="$2"
    local content="$3"
    local label="$4"

    local marker_line
    marker_line=$(grep -n "$marker" "$file" | head -1 | cut -d: -f1)

    if [ -z "$marker_line" ]; then
        printf "\n\n%s" "$content" >> "$file"
        log_ok "$label — dodano instrukcje workflow"
        inc INSTALLED
        return
    fi

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

    head -n $((start - 1)) "$file" | sed -e :a -e '/^\n*$/{$d;N;ba}' > "${file}.tmp"
    printf "\n\n%s" "$content" >> "${file}.tmp"
    mv "${file}.tmp" "$file"
    log_update "$label — zaktualizowano instrukcje workflow"
    inc UPDATED
}

# --- CLAUDE.md ---
echo ""
echo -e "  ${FILE} ${BOLD}CLAUDE.md${NC} ${DIM}(Klaudiusz)${NC}"
CLAUDE_MARKER="## Twoja rola"
CLAUDE_CONTENT="$(cat "$SCRIPT_DIR/klaudiusz.md")"

if [ -f "CLAUDE.md" ]; then
    if grep -qF "$CLAUDE_MARKER" "CLAUDE.md"; then
        if $FORCE; then
            update_file "CLAUDE.md" "$CLAUDE_MARKER" "$CLAUDE_CONTENT" "CLAUDE.md"
        else
            log_skip "CLAUDE.md — już zainstalowany (użyj --force)"
            inc SKIPPED
        fi
    else
        printf "\n\n%s" "$CLAUDE_CONTENT" >> "CLAUDE.md"
        log_ok "CLAUDE.md — dodano instrukcje workflow"
        inc INSTALLED
    fi
else
    echo "$CLAUDE_CONTENT" > "CLAUDE.md"
    log_ok "CLAUDE.md — utworzono"
    inc INSTALLED
fi

# --- GEMINI.md ---
echo -e "  ${FILE} ${BOLD}GEMINI.md${NC} ${DIM}(Sokół)${NC}"
GEMINI_MARKER="## Twoja rola"
GEMINI_CONTENT="$(cat "$SCRIPT_DIR/sokol.md")"

if [ -f "GEMINI.md" ]; then
    if grep -qF "$GEMINI_MARKER" "GEMINI.md"; then
        if $FORCE; then
            update_file "GEMINI.md" "$GEMINI_MARKER" "$GEMINI_CONTENT" "GEMINI.md"
        else
            log_skip "GEMINI.md — już zainstalowany (użyj --force)"
            inc SKIPPED
        fi
    else
        printf "\n\n" >> "GEMINI.md"
        cat "$SCRIPT_DIR/sokol.md" >> "GEMINI.md"
        log_ok "GEMINI.md — dodano instrukcje workflow"
        inc INSTALLED
    fi
else
    cp "$SCRIPT_DIR/sokol.md" "GEMINI.md"
    log_ok "GEMINI.md — utworzono"
    inc INSTALLED
fi

# --- Struktura MD/ ---
echo -e "  ${FOLDER} ${BOLD}MD/${NC} ${DIM}(struktura dokumentów)${NC}"
mkdir -p MD/plans MD/research

# issues_sokol.md — tracking issues ze statusami
if [ ! -f "MD/issues_sokol.md" ]; then
    cat > "MD/issues_sokol.md" << 'ISSUES'
# Issues — [nazwa projektu]

## Ostatni skan
- **Data:** —
- **Scope:** brak (pierwszy skan nie wykonany)
- **Agent:** —
- **Commit:** —

(Brak issues — Sokół nie wykonał jeszcze pierwszego skanu)
ISSUES
    log_ok "MD/issues_sokol.md — utworzono"
    inc INSTALLED
else
    log_skip "MD/issues_sokol.md — już istnieje"
    inc SKIPPED
fi

# memory.md — pamięć agentów (co zrobione, co odrzucone)
if [ ! -f "MD/memory.md" ]; then
    cat > "MD/memory.md" << 'MEMORY'
# Memory — [nazwa projektu]

## Zrobione
| Data | Co | Plan | Kto |
|------|----|------|-----|

## Odrzucone / Debunked
| Data | Propozycja | Powód odrzucenia | Kto odrzucił |
|------|-----------|------------------|--------------|
MEMORY
    log_ok "MD/memory.md — utworzono"
    inc INSTALLED
else
    log_skip "MD/memory.md — już istnieje"
    inc SKIPPED
fi

# --- Szablony planów ---
mkdir -p templates

# Usuń stary szablon jeśli istnieje (zastąpiony przez single + batch)
if [ -f "templates/plan_template.md" ]; then
    rm "templates/plan_template.md"
    echo -e "  🗑️  ${DIM}Usunięto stary plan_template.md (zastąpiony przez single + batch)${NC}"
fi

for tpl in plan_single.md plan_batch.md; do
    echo -e "  ${FILE} ${BOLD}templates/${tpl}${NC}"
    if [ ! -f "templates/${tpl}" ] || $FORCE; then
        cp "$SCRIPT_DIR/templates/${tpl}" "templates/${tpl}"
        if $FORCE; then
            log_update "${tpl} — zaktualizowano"
            inc UPDATED
        else
            log_ok "${tpl} — skopiowano"
            inc INSTALLED
        fi
    else
        log_skip "${tpl} — już istnieje"
        inc SKIPPED
    fi
done

# --- Smoketest ---
echo ""
echo -e "${DIM}──────────────────────────────────────────────${NC}"
echo -e "  🧪 ${BOLD}Smoketest${NC}"
echo ""

smoke_check() {
    local description="$1"
    local condition="$2"

    if eval "$condition"; then
        echo -e "     ${CHECK} ${description}"
        inc SMOKE_PASS
    else
        echo -e "     ${FAIL} ${description}"
        inc SMOKE_FAIL
    fi
}

smoke_check "MD/plans/ istnieje"                     "[ -d MD/plans ]"
smoke_check "MD/research/ istnieje"                  "[ -d MD/research ]"
smoke_check "MD/issues_sokol.md istnieje"                  "[ -f MD/issues_sokol.md ]"
smoke_check "MD/memory.md istnieje"                  "[ -f MD/memory.md ]"
smoke_check "CLAUDE.md istnieje"                    "[ -f CLAUDE.md ]"
smoke_check "CLAUDE.md zawiera marker workflow"     "grep -qF '## Twoja rola' CLAUDE.md 2>/dev/null"
smoke_check "CLAUDE.md zawiera rolę Klaudiusza"     "grep -qF 'Klaudiusz' CLAUDE.md 2>/dev/null"
smoke_check "CLAUDE.md zawiera auto-deploy"         "grep -qF 'docker compose' CLAUDE.md 2>/dev/null"
smoke_check "CLAUDE.md zawiera prompt zwrotny"      "grep -qF 'prompt zwrotny' CLAUDE.md 2>/dev/null"
smoke_check "GEMINI.md istnieje"                    "[ -f GEMINI.md ]"
smoke_check "GEMINI.md zawiera marker workflow"     "grep -qF '## Twoja rola' GEMINI.md 2>/dev/null"
smoke_check "GEMINI.md zawiera rolę Sokoła"         "grep -qF 'Sokół' GEMINI.md 2>/dev/null"
smoke_check "templates/plan_single.md istnieje"     "[ -f templates/plan_single.md ]"
smoke_check "plan_single zawiera severity"          "grep -qF 'Severity' templates/plan_single.md 2>/dev/null"
smoke_check "plan_single zawiera źródło"            "grep -qF 'Źródło' templates/plan_single.md 2>/dev/null"
smoke_check "templates/plan_batch.md istnieje"      "[ -f templates/plan_batch.md ]"
smoke_check "plan_batch zawiera kolejność"          "grep -qF 'Kolejność' templates/plan_batch.md 2>/dev/null"
smoke_check "plan_batch zawiera tabelę issues"      "grep -qF 'Issues w tym batchu' templates/plan_batch.md 2>/dev/null"

# --- Podsumowanie ---
echo ""
echo -e "${DIM}──────────────────────────────────────────────${NC}"
echo ""

TOTAL=$((INSTALLED + UPDATED + SKIPPED))

if [ $SMOKE_FAIL -eq 0 ]; then
    echo -e "  ${ROCKET} ${BOLD}${GREEN}Wszystko OK!${NC}"
else
    echo -e "  ${WARN} ${BOLD}${YELLOW}Smoketest: $SMOKE_FAIL problemów${NC}"
fi

echo ""
echo -e "  ${DIM}Zainstalowano: ${INSTALLED}  │  Zaktualizowano: ${UPDATED}  │  Pominięto: ${SKIPPED}${NC}"
SMOKE_TOTAL=$((SMOKE_PASS + SMOKE_FAIL))
  echo -e "  ${DIM}Smoketest:     ${SMOKE_PASS}/${SMOKE_TOTAL} passed${NC}"
echo ""
