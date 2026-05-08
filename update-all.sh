#!/bin/bash

# Aktualizuje workflow we wszystkich projektach (--force)
# Użycie:
#   bash update-all.sh
#   bash update-all.sh --verbose

set -euo pipefail

# --- Kolory i symbole ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

inc() { eval "$1=\$(($1 + 1))"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOX_WIDTH=47

print_box() {
    local title="$1"
    local title_len=${#title}
    local padding=$((BOX_WIDTH - title_len))
    local left=0
    local right=0
    local border

    if [ "$padding" -lt 0 ]; then
        title="${title:0:$BOX_WIDTH}"
        title_len=${#title}
        padding=0
    fi

    left=$((padding / 2))
    right=$((padding - left))
    printf -v border '%*s' "$BOX_WIDTH" ''
    border=${border// /═}

    echo -e "${BOLD}${CYAN}╔${border}╗${NC}"
    printf "%b║%*s%s%*s║%b\n" "${BOLD}${CYAN}" "$left" "" "$title" "$right" "" "${NC}"
    echo -e "${BOLD}${CYAN}╚${border}╝${NC}"
}

VERBOSE=false
for arg in "$@"; do
    case "$arg" in
        --verbose)
            VERBOSE=true
            ;;
        -h|--help)
            echo "Użycie: bash update-all.sh [--verbose]"
            exit 0
            ;;
        *)
            echo -e "${RED}Nieznana opcja: $arg${NC}" >&2
            echo "Użycie: bash update-all.sh [--verbose]" >&2
            exit 1
            ;;
    esac
done

PROJECTS=(
    "$HOME/projects/rsi"
    "$HOME/projects/Hydra"
    "$HOME/projects/d3pth"
    "$HOME/projects/tgramai"
)

# --- Header ---
echo ""
print_box "Update All — Popek Agent Workflow"
echo ""
if $VERBOSE; then
    echo -e "  ${DIM}Projekty: ${#PROJECTS[@]}  │  Tryb: --force --verbose${NC}"
else
    echo -e "  ${DIM}Projekty: ${#PROJECTS[@]}  │  Tryb: --force${NC}"
fi
echo ""

TOTAL_OK=0
TOTAL_SKIP=0
TOTAL_FAIL=0
RESULTS=()

for project in "${PROJECTS[@]}"; do
    name=$(basename "$project")

    if [ ! -d "$project" ]; then
        echo -e "  ${YELLOW}⏭️  ${name}${NC} ${DIM}— katalog nie istnieje${NC}"
        RESULTS+=("⏭️  $name — nie istnieje")
        inc TOTAL_SKIP
        echo ""
        continue
    fi

    install_status=0
    output=$(bash "$SCRIPT_DIR/install.sh" "$project" --force 2>&1) || install_status=$?

    if $VERBOSE; then
        echo -e "  ${BOLD}📦 ${name}${NC}"
        echo -e "  ${DIM}────────────────────────────────${NC}"
        echo "$output"
    fi

    summary_line=$(echo "$output" | grep -E "Zainstalowano:" | tail -1 || true)
    smoke_line=$(echo "$output" | grep -E "Smoketest:" | tail -1 || true)
    installed="?"
    updated="?"
    skipped="?"
    smoke="brak"

    if [ -n "$summary_line" ]; then
        counts=$(echo "$summary_line" | sed -E 's/.*Zainstalowano:[[:space:]]*([0-9]+).*Zaktualizowano:[[:space:]]*([0-9]+).*Pominięto:[[:space:]]*([0-9]+).*/\1 \2 \3/')
        if [ "$counts" != "$summary_line" ]; then
            read -r installed updated skipped <<< "$counts"
        fi
    fi

    if [ -n "$smoke_line" ]; then
        parsed_smoke=$(echo "$smoke_line" | sed -E 's/.*Smoketest:[[:space:]]*([0-9]+\/[0-9]+).*/\1/')
        if [ "$parsed_smoke" != "$smoke_line" ]; then
            smoke="$parsed_smoke"
        elif echo "$smoke_line" | grep -q "problemów"; then
            smoke="z uwagami"
        fi
    fi

    if echo "$output" | grep -q "Wszystko OK"; then
        RESULTS+=("✅ $name")
        inc TOTAL_OK
        echo -e "  📦 ${BOLD}$(printf '%-8s' "$name")${NC} ${GREEN}✅ ${updated} aktualizacji, ${installed} nowych, ${skipped} bez zmian, smoke ${smoke}${NC}"
    elif echo "$output" | grep -q "pomijam"; then
        RESULTS+=("⏭️  $name — brak workflow, pominięto")
        inc TOTAL_SKIP
        echo -e "  📦 ${BOLD}$(printf '%-8s' "$name")${NC} ${YELLOW}⏭️  pominięto — workflow nie był zainstalowany${NC}"
    elif echo "$output" | grep -q "problemów"; then
        RESULTS+=("⚠️  $name — smoketest z uwagami")
        inc TOTAL_FAIL
        echo -e "  📦 ${BOLD}$(printf '%-8s' "$name")${NC} ${YELLOW}⚠️  ${updated} aktualizacji, ${installed} nowych, ${skipped} bez zmian, smoke ${smoke}${NC}"
    elif [ "$install_status" -ne 0 ]; then
        RESULTS+=("❌ $name — install.sh zakończył się błędem")
        inc TOTAL_FAIL
        echo -e "  📦 ${BOLD}$(printf '%-8s' "$name")${NC} ${RED}❌ błąd instalatora, odpal --verbose po szczegóły${NC}"
    else
        RESULTS+=("✅ $name")
        inc TOTAL_OK
        echo -e "  📦 ${BOLD}$(printf '%-8s' "$name")${NC} ${GREEN}✅ ${updated} aktualizacji, ${installed} nowych, ${skipped} bez zmian, smoke ${smoke}${NC}"
    fi

    $VERBOSE && echo ""
done

# --- Podsumowanie ---
echo ""
print_box "Podsumowanie"
echo ""

if $VERBOSE; then
    for result in "${RESULTS[@]}"; do
        echo -e "  $result"
    done
    echo ""
fi

echo -e "  ${DIM}─────────────────────────────────────${NC}"

if [ $TOTAL_FAIL -eq 0 ] && [ $TOTAL_SKIP -eq 0 ]; then
    echo -e "  🎉 ${BOLD}${GREEN}Wszystkie projekty zaktualizowane!${NC}"
elif [ $TOTAL_FAIL -eq 0 ]; then
    echo -e "  ✅ ${GREEN}OK: ${TOTAL_OK}${NC}  ${YELLOW}Pominięte: ${TOTAL_SKIP}${NC}"
else
    echo -e "  ✅ ${GREEN}OK: ${TOTAL_OK}${NC}  ${RED}Błędy: ${TOTAL_FAIL}${NC}  ${YELLOW}Pominięte: ${TOTAL_SKIP}${NC}"
fi

if ! $VERBOSE; then
    echo ""
    echo -e "  ${DIM}P.S. Chcesz więcej szczegółów? Odpal: bash update-all.sh --verbose${NC}"
fi
echo ""
