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
    HAS_AGENTS=false
    [ -f "CLAUDE.md" ] && grep -qF "$MARKER" "CLAUDE.md" 2>/dev/null && HAS_CLAUDE=true
    [ -f "GEMINI.md" ] && grep -qF "$MARKER" "GEMINI.md" 2>/dev/null && HAS_GEMINI=true
    [ -f "AGENTS.md" ] && grep -qF "$MARKER" "AGENTS.md" 2>/dev/null && HAS_AGENTS=true

    if ! $HAS_CLAUDE && ! $HAS_GEMINI && ! $HAS_AGENTS; then
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

# --- Helper: usuwa końcowe puste linie ze stdin ---
# POSIX awk — odporne na CRLF, tabulatory w pustych liniach, brak trailing newline
strip_trailing_blanks() {
    awk '
        /^[[:space:]]*\r?$/ { blanks = blanks "\n"; next }
        { printf "%s%s\n", blanks, $0; blanks = "" }
    '
}

# Usuń stare jednozdaniowe role z prefiksu projektu.
# Część repo miała własny opis nad blokiem workflow; po zamianie ról taka linia
# mogłaby przebić właściwą instrukcję z aktualnego bloku.
strip_stale_workflow_role_lines() {
    awk '!/^Jesteś \*\*(Klaudiusz|Sokół)\*\*/ { print }'
}

# --- Funkcja: podmień / wstaw blok workflow w pliku (idempotentnie, z deduplikacją wsteczną) ---
#
# Strategia (deterministyczna, niezależna od odstępów):
#   1. Znajdź PIERWSZE wystąpienie '^# Instrukcje dla ' — to początek bloku workflow.
#      Wszystko od tej linii do EOF traktujemy jako "zarządzaną" treść install.sh.
#   2. Obetnij plik do tej linii (exclusive). To automatycznie usuwa WSZYSTKIE
#      zalegające duplikaty nagłówka pozostawione przez wcześniejsze wersje skryptu.
#   3. `strip_trailing_blanks` na zachowanej treści użytkownika.
#   4. Doklej świeżą treść z dokładnie jedną pustą linią jako separator (2 × \n).
#
# Argumenty: file, content, label, mode (install|update — kontroluje liczniki/komunikat)
update_file() {
    local file="$1"
    local content="$2"
    local label="$3"
    local mode="${4:-update}"

    # Liczba istniejących nagłówków — do raportowania ile duplikatów wyczyszczono
    # (grep zwraca exit 1 gdy brak dopasowań → || true wymagane przez `set -e`)
    local header_count
    header_count=$(grep -c '^# Instrukcje dla ' "$file" 2>/dev/null || true)
    [ -z "$header_count" ] && header_count=0

    # Linia pierwszego nagłówka workflow (jeśli istnieje)
    # Pipeline z grep + head: grep exit 1 łamie `pipefail` → || true na całości
    local header_line
    header_line=$( { grep -n '^# Instrukcje dla ' "$file" || true; } | head -1 | cut -d: -f1)

    local tmp="${file}.tmp.$$"
    : > "$tmp"

    if [ -n "$header_line" ]; then
        if [ "$header_line" -gt 1 ]; then
            head -n $((header_line - 1)) "$file" | strip_trailing_blanks | strip_stale_workflow_role_lines > "$tmp"
        fi
        # header_line == 1 → tmp pozostaje pusty (cały plik to workflow)
    else
        # Brak nagłówka workflow — zachowaj całą dotychczasową treść użytkownika
        strip_trailing_blanks < "$file" | strip_stale_workflow_role_lines > "$tmp"
    fi

    if [ -s "$tmp" ]; then
        # tmp kończy się na \n (po strip_trailing_blanks); dodaj 1 dodatkowy \n → 1 pusta linia separatora
        printf '\n%s\n' "$content" >> "$tmp"
    else
        printf '%s\n' "$content" > "$tmp"
    fi

    mv "$tmp" "$file"

    if [ "$mode" = "install" ]; then
        log_ok "$label — dodano instrukcje workflow"
        inc INSTALLED
    else
        if [ "$header_count" -gt 1 ]; then
            local dups=$((header_count - 1))
            log_update "$label — zaktualizowano instrukcje workflow (usunięto $dups duplikat(ów) nagłówka)"
        else
            log_update "$label — zaktualizowano instrukcje workflow"
        fi
        inc UPDATED
    fi
}

# --- CLAUDE.md (Claude Code) — używa roli Sokoła ---
echo ""
echo -e "  ${FILE} ${BOLD}CLAUDE.md${NC} ${DIM}(Sokół — Claude Code)${NC}"
CLAUDE_MARKER="## Twoja rola"
CLAUDE_CONTENT="$(cat "$SCRIPT_DIR/sokol.md")"

if [ -f "CLAUDE.md" ]; then
    HAS_WORKFLOW=false
    grep -qF "$CLAUDE_MARKER" "CLAUDE.md" 2>/dev/null && HAS_WORKFLOW=true
    grep -q '^# Instrukcje dla ' "CLAUDE.md" 2>/dev/null && HAS_WORKFLOW=true

    if $HAS_WORKFLOW; then
        if $FORCE; then
            update_file "CLAUDE.md" "$CLAUDE_CONTENT" "CLAUDE.md" update
        else
            log_skip "CLAUDE.md — już zainstalowany (użyj --force)"
            inc SKIPPED
        fi
    else
        update_file "CLAUDE.md" "$CLAUDE_CONTENT" "CLAUDE.md" install
    fi
else
    printf '%s\n' "$CLAUDE_CONTENT" > "CLAUDE.md"
    log_ok "CLAUDE.md — utworzono"
    inc INSTALLED
fi

# --- GEMINI.md ---
echo -e "  ${FILE} ${BOLD}GEMINI.md${NC} ${DIM}(Sokół)${NC}"
GEMINI_MARKER="## Twoja rola"
GEMINI_CONTENT="$(cat "$SCRIPT_DIR/sokol.md")"

if [ -f "GEMINI.md" ]; then
    HAS_WORKFLOW=false
    grep -qF "$GEMINI_MARKER" "GEMINI.md" 2>/dev/null && HAS_WORKFLOW=true
    grep -q '^# Instrukcje dla ' "GEMINI.md" 2>/dev/null && HAS_WORKFLOW=true

    if $HAS_WORKFLOW; then
        if $FORCE; then
            update_file "GEMINI.md" "$GEMINI_CONTENT" "GEMINI.md" update
        else
            log_skip "GEMINI.md — już zainstalowany (użyj --force)"
            inc SKIPPED
        fi
    else
        update_file "GEMINI.md" "$GEMINI_CONTENT" "GEMINI.md" install
    fi
else
    printf '%s\n' "$GEMINI_CONTENT" > "GEMINI.md"
    log_ok "GEMINI.md — utworzono"
    inc INSTALLED
fi

# --- AGENTS.md (Codex CLI) — używa roli Klaudiusza ---
echo -e "  ${FILE} ${BOLD}AGENTS.md${NC} ${DIM}(Klaudiusz — Codex)${NC}"
AGENTS_MARKER="## Twoja rola"
AGENTS_CONTENT="$(cat "$SCRIPT_DIR/klaudiusz.md")"

if [ -f "AGENTS.md" ]; then
    HAS_WORKFLOW=false
    grep -qF "$AGENTS_MARKER" "AGENTS.md" 2>/dev/null && HAS_WORKFLOW=true
    grep -q '^# Instrukcje dla ' "AGENTS.md" 2>/dev/null && HAS_WORKFLOW=true

    if $HAS_WORKFLOW; then
        if $FORCE; then
            update_file "AGENTS.md" "$AGENTS_CONTENT" "AGENTS.md" update
        else
            log_skip "AGENTS.md — już zainstalowany (użyj --force)"
            inc SKIPPED
        fi
    else
        update_file "AGENTS.md" "$AGENTS_CONTENT" "AGENTS.md" install
    fi
else
    printf '%s\n' "$AGENTS_CONTENT" > "AGENTS.md"
    log_ok "AGENTS.md — utworzono"
    inc INSTALLED
fi

# --- agents_catalog.md (lokalny katalog 60 agentów dla Sokoła) ---
# Sokół nie ma WebFetch — czyta TEN plik zamiast halucynować nazwy z URL.
echo -e "  ${FILE} ${BOLD}agents_catalog.md${NC} ${DIM}(katalog dla Sokoła)${NC}"
if [ ! -f "agents_catalog.md" ] || $FORCE; then
    cp "$SCRIPT_DIR/agents_catalog.md" "agents_catalog.md"
    if $FORCE; then
        log_update "agents_catalog.md — zaktualizowano"
        inc UPDATED
    else
        log_ok "agents_catalog.md — skopiowano"
        inc INSTALLED
    fi
else
    log_skip "agents_catalog.md — już istnieje"
    inc SKIPPED
fi

# --- scripts/notify.sh — powiadomienie po wdrożeniu (cross-platform popup) ---
# Klaudiusz wywołuje ten skrypt po zielonym rebuildzie i przy konfliktach push/rollback.
# Bez tego skryptu wszystkie wywołania `bash scripts/notify.sh "..."` z klaudiusz.md
# kończyłyby się "No such file or directory" w docelowym projekcie.
echo -e "  ${FILE} ${BOLD}scripts/notify.sh${NC} ${DIM}(powiadomienie orkiestratora)${NC}"
mkdir -p scripts
if [ ! -f "scripts/notify.sh" ] || $FORCE; then
    cp "$SCRIPT_DIR/scripts/notify.sh" "scripts/notify.sh"
    chmod +x "scripts/notify.sh"
    if $FORCE; then
        log_update "scripts/notify.sh — zaktualizowano"
        inc UPDATED
    else
        log_ok "scripts/notify.sh — skopiowano"
        inc INSTALLED
    fi
else
    log_skip "scripts/notify.sh — już istnieje (zachowuję wersję projektu)"
    inc SKIPPED
fi

# --- Struktura MD/ ---
echo -e "  ${FOLDER} ${BOLD}MD/${NC} ${DIM}(struktura dokumentów)${NC}"
mkdir -p MD/plans

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
| Data | Co | Opis (2-3 zdania) | Plan | Kto |
|------|----|-------------------|------|-----|

> **Reguła pisania:** wpis dodaje TYLKO ten kto wykonał pracę.
> - **Klaudiusz** pisze po deployu (kolumna Kto = `Klaudiusz`).
> - **Sokół** pisze TYLKO po Quick fixie lub retroaktywnej finalizacji (kolumna Kto = `Sokół`).
> Kolumna **Kto** jest OBOWIĄZKOWA — bez niej wpis nieważny.

## Odrzucone / Debunked
| Data | Propozycja | Powód odrzucenia (2-3 zdania) | Kto odrzucił |
|------|-----------|-------------------------------|--------------|

> **Reguła pisania:** Sokół dopisuje gdy issue dostaje status WONTFIX. Klaudiusz dopisuje gdy w trakcie planu obali pomysł argumentem (pushback).
MEMORY
    log_ok "MD/memory.md — utworzono"
    inc INSTALLED
else
    log_skip "MD/memory.md — już istnieje"
    inc SKIPPED
fi

# TODO.md — kolejka zadań (OPEN / DONE / Hygiene)
TODO_LEGACY=false  # flaga: pre-existing TODO.md bez naszych sekcji (smoketest user'i)
if [ ! -f "MD/TODO.md" ]; then
    cat > "MD/TODO.md" << 'TODOS'
# TODO — [nazwa projektu]

## OPEN
Aktywne zadania do zrobienia. Każdy task = 1 wiersz tabeli.

| # | Task | Severity | Źródło | Status | Kto zgłosił |
|---|------|----------|--------|--------|-------------|

**Statusy:** OPEN → IN_PROGRESS → DONE / WONTFIX

## DONE
Zadania zakończone — przeniesione tu po wdrożeniu (status WDROŻONY w planie).

| Data | Task | Plan | Kto wdrożył |
|------|------|------|-------------|

## Hygiene
Drobne porządki, długi techniczne, "kiedyś warto byłoby" — zrobimy gdy będzie chwila. Nie blokuje workflow.

| # | Co | Gdzie | Kto zgłosił |
|---|----|-------|-------------|

> **Reguła:** Jeśli Klaudiusz w prompcie zwrotnym zgłosi "Dług techniczny" — Sokół dopisuje go do **Hygiene**. Drobne issues z LOW severity które nie wymagają planu — też tutaj.
TODOS
    log_ok "MD/TODO.md — utworzono"
    inc INSTALLED
else
    log_skip "MD/TODO.md — już istnieje"
    inc SKIPPED
    # Sprawdź czy istniejący plik ma standardowe sekcje workflow.
    # Jeśli nie — wypisz inline ostrzeżenie (legacy format z czasów przed standaryzacją).
    if ! grep -qF '## OPEN' "MD/TODO.md" 2>/dev/null \
       || ! grep -qF '## DONE' "MD/TODO.md" 2>/dev/null \
       || ! grep -qF '## Hygiene' "MD/TODO.md" 2>/dev/null; then
        TODO_LEGACY=true
        missing=()
        grep -qF '## OPEN' "MD/TODO.md" 2>/dev/null    || missing+=("OPEN")
        grep -qF '## DONE' "MD/TODO.md" 2>/dev/null    || missing+=("DONE")
        grep -qF '## Hygiene' "MD/TODO.md" 2>/dev/null || missing+=("Hygiene")
        echo -e "     ${DIM}${YELLOW}↳ legacy format: brak sekcji ${missing[*]}. Workflow je używa do trackingu.${NC}"
        echo -e "     ${DIM}${YELLOW}  Migracja (opcjonalna): dokleić te sekcje do MD/TODO.md, lub przenieść stary do MD/TODO_legacy.md i odpalić install ponownie.${NC}"
    fi
fi

# archive/ — katalog na zarchiwizowane plany (po wdrożeniu)
mkdir -p MD/archive

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
smoke_check "MD/issues_sokol.md istnieje"                  "[ -f MD/issues_sokol.md ]"
smoke_check "MD/memory.md istnieje"                  "[ -f MD/memory.md ]"
smoke_check "MD/TODO.md istnieje"                    "[ -f MD/TODO.md ]"
smoke_check "MD/archive/ istnieje"                   "[ -d MD/archive ]"
# Strict check tylko dla świeżych instalacji. Legacy pre-existing TODO.md (np. po polsku z customowym formatem)
# raportujemy inline jako warning powyżej — w smoketest pass'uje gdy plik ma jakąkolwiek strukturę (>5 linii).
if $TODO_LEGACY; then
    smoke_check "MD/TODO.md ma strukturę (legacy format zachowany)" "[ \"\$(wc -l < MD/TODO.md 2>/dev/null)\" -gt 5 ]"
else
    smoke_check "MD/TODO.md ma sekcje OPEN/DONE/Hygiene" "grep -qF '## OPEN' MD/TODO.md && grep -qF '## DONE' MD/TODO.md && grep -qF '## Hygiene' MD/TODO.md"
fi
smoke_check "agents_catalog.md istnieje"             "[ -f agents_catalog.md ]"
smoke_check "agents_catalog.md zawiera python-reviewer" "grep -qF 'python-reviewer' agents_catalog.md 2>/dev/null"
smoke_check "agents_catalog.md zawiera aqua-combo"   "grep -qF 'aqua-combo' agents_catalog.md 2>/dev/null"
smoke_check "scripts/notify.sh istnieje"             "[ -f scripts/notify.sh ]"
smoke_check "scripts/notify.sh wykonywalny"          "[ -x scripts/notify.sh ]"
smoke_check "CLAUDE.md ma marker wersji workflow"    "grep -qE 'workflow-version: [0-9]{4}\.[0-9]{2}\.[0-9]{2}' CLAUDE.md 2>/dev/null"
smoke_check "GEMINI.md ma marker wersji workflow"    "grep -qE 'workflow-version: [0-9]{4}\.[0-9]{2}\.[0-9]{2}' GEMINI.md 2>/dev/null"
smoke_check "AGENTS.md ma marker wersji workflow"    "grep -qE 'workflow-version: [0-9]{4}\.[0-9]{2}\.[0-9]{2}' AGENTS.md 2>/dev/null"
smoke_check "CLAUDE.md istnieje"                    "[ -f CLAUDE.md ]"
smoke_check "CLAUDE.md zawiera marker workflow"     "grep -qF '## Twoja rola' CLAUDE.md 2>/dev/null"
smoke_check "CLAUDE.md ma dokładnie 1 nagłówek '# Instrukcje dla'" "[ \"\$(grep -c '^# Instrukcje dla ' CLAUDE.md 2>/dev/null)\" = '1' ]"
smoke_check "CLAUDE.md zawiera dokładną rolę Sokoła" "grep -qF 'Jesteś **Sokół**' CLAUDE.md 2>/dev/null"
smoke_check "CLAUDE.md nie zawiera starej roli Klaudiusza" "! grep -qF 'Jesteś **Klaudiusz**' CLAUDE.md 2>/dev/null"
smoke_check "GEMINI.md istnieje"                    "[ -f GEMINI.md ]"
smoke_check "GEMINI.md zawiera marker workflow"     "grep -qF '## Twoja rola' GEMINI.md 2>/dev/null"
smoke_check "GEMINI.md ma dokładnie 1 nagłówek '# Instrukcje dla'" "[ \"\$(grep -c '^# Instrukcje dla ' GEMINI.md 2>/dev/null)\" = '1' ]"
smoke_check "GEMINI.md zawiera dokładną rolę Sokoła" "grep -qF 'Jesteś **Sokół**' GEMINI.md 2>/dev/null"
smoke_check "GEMINI.md nie zawiera roli Klaudiusza" "! grep -qF 'Jesteś **Klaudiusz**' GEMINI.md 2>/dev/null"
smoke_check "AGENTS.md istnieje"                    "[ -f AGENTS.md ]"
smoke_check "AGENTS.md zawiera marker workflow"     "grep -qF '## Twoja rola' AGENTS.md 2>/dev/null"
smoke_check "AGENTS.md ma dokładnie 1 nagłówek '# Instrukcje dla'" "[ \"\$(grep -c '^# Instrukcje dla ' AGENTS.md 2>/dev/null)\" = '1' ]"
smoke_check "AGENTS.md zawiera dokładną rolę Klaudiusza" "grep -qF 'Jesteś **Klaudiusz**' AGENTS.md 2>/dev/null"
smoke_check "AGENTS.md nie zawiera roli Sokoła"      "! grep -qF 'Jesteś **Sokół**' AGENTS.md 2>/dev/null"
smoke_check "AGENTS.md zawiera auto-deploy"         "grep -qF 'docker compose' AGENTS.md 2>/dev/null"
smoke_check "AGENTS.md zawiera prompt zwrotny"      "grep -qF 'prompt zwrotny' AGENTS.md 2>/dev/null"
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
