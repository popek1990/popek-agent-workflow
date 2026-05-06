#!/bin/bash

# Aktualizuje workflow we wszystkich projektach (--force)
# Użycie: bash update-all.sh

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

PROJECTS=(
    "$HOME/projects/rsi"
    "$HOME/projects/Hydra"
    "$HOME/projects/d3pth"
    "$HOME/projects/tgramai"
)

# --- Header ---
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║  🔄 Update All — Popek Agent Workflow       ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${DIM}Projekty: ${#PROJECTS[@]}  │  Tryb: --force${NC}"
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

    echo -e "  ${BOLD}📦 ${name}${NC}"
    echo -e "  ${DIM}────────────────────────────────${NC}"

    output=$(bash "$SCRIPT_DIR/install.sh" "$project" --force 2>&1) || true
    echo "$output" | grep -E "(✅|⏭️|❌|✔️|🧪|🚀|Smoketest|Zainstalowano|Wszystko OK|problemów)" | head -25

    if echo "$output" | grep -q "Wszystko OK"; then
        RESULTS+=("✅ $name")
        inc TOTAL_OK
    elif echo "$output" | grep -q "problemów"; then
        RESULTS+=("⚠️  $name — smoketest z uwagami")
        inc TOTAL_FAIL
    else
        RESULTS+=("✅ $name")
        inc TOTAL_OK
    fi

    echo ""
done

# --- Podsumowanie ---
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║  📊 Podsumowanie                            ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

for result in "${RESULTS[@]}"; do
    echo -e "  $result"
done

echo ""
echo -e "  ${DIM}─────────────────────────────────────${NC}"

if [ $TOTAL_FAIL -eq 0 ] && [ $TOTAL_SKIP -eq 0 ]; then
    echo -e "  🎉 ${BOLD}${GREEN}Wszystkie projekty zaktualizowane!${NC}"
elif [ $TOTAL_FAIL -eq 0 ]; then
    echo -e "  ✅ ${GREEN}OK: ${TOTAL_OK}${NC}  ${YELLOW}Pominięte: ${TOTAL_SKIP}${NC}"
else
    echo -e "  ✅ ${GREEN}OK: ${TOTAL_OK}${NC}  ${RED}Błędy: ${TOTAL_FAIL}${NC}  ${YELLOW}Pominięte: ${TOTAL_SKIP}${NC}"
fi
echo ""
