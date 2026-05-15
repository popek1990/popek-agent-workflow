#!/bin/bash
# Self-smoketest dla repo workflow.
# Sprawdza wewnętrzną spójność: markery, referencje plików, wersje.
# Uruchom z korzenia repo: bash scripts/test-repo.sh

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

PASS=0
FAIL=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }

check() {
    local description="$1"
    local condition="$2"
    if eval "$condition" 2>/dev/null; then
        ok "$description"
    else
        fail "$description"
    fi
}

echo ""
echo "═══════════════════════════════════════════════"
echo "  Self-smoketest: repo workflow"
echo "═══════════════════════════════════════════════"
echo ""

echo "▸ Pliki źródłowe"
check "builder.md istnieje"                 "[ -f builder.md ]"
check "sokol.md istnieje"                   "[ -f sokol.md ]"
check "workflow.md istnieje"                "[ -f workflow.md ]"
check "cel.md istnieje"                     "[ -f cel.md ]"
check "README.md istnieje"                  "[ -f README.md ]"
check "install.sh istnieje"                 "[ -f install.sh ]"
check "CHANGELOG.md istnieje"               "[ -f CHANGELOG.md ]"
check "agents_catalog.md istnieje"          "[ -f agents_catalog.md ]"
check ".workflow/config istnieje"           "[ -f .workflow/config ]"
check "scripts/notify.sh istnieje"          "[ -f scripts/notify.sh ]"
check "templates/plan_single.md istnieje"   "[ -f templates/plan_single.md ]"
check "templates/plan_batch.md istnieje"    "[ -f templates/plan_batch.md ]"
check "update-all.sh składnia bash OK"       "bash -n update-all.sh"
check "install.sh składnia bash OK"          "bash -n install.sh"

echo ""
echo "▸ Markery (install.sh wykrywa instalację po nich)"
check "builder.md ma marker '## Twoja rola'"    "grep -qF '## Twoja rola' builder.md"
check "sokol.md ma marker '## Twoja rola'"      "grep -qF '## Twoja rola' sokol.md"
check "install.sh CLAUDE_MARKER = '## Twoja rola'"  "grep -qE 'CLAUDE_MARKER=\"## Twoja rola\"' install.sh"
check "install.sh GEMINI_MARKER = '## Twoja rola'"  "grep -qE 'GEMINI_MARKER=\"## Twoja rola\"' install.sh"
check "install.sh AGENTS_MARKER = '## Twoja rola'"  "grep -qE 'AGENTS_MARKER=\"## Twoja rola\"' install.sh"

echo ""
echo "▸ Wersjonowanie workflow"
BV=$(grep -oE 'workflow-version: [0-9]{4}\.[0-9]{2}\.[0-9]{2}' builder.md | head -1 || true)
SV=$(grep -oE 'workflow-version: [0-9]{4}\.[0-9]{2}\.[0-9]{2}' sokol.md | head -1 || true)
WV=$(grep -oE 'workflow-version: [0-9]{4}\.[0-9]{2}\.[0-9]{2}' workflow.md | head -1 || true)
check "builder.md ma marker workflow-version"    "[ -n \"$BV\" ]"
check "sokol.md ma marker workflow-version"      "[ -n \"$SV\" ]"
check "workflow.md ma marker workflow-version"   "[ -n \"$WV\" ]"
check "builder.md i sokol.md mają tę samą wersję"    "[ \"$BV\" = \"$SV\" ] && [ -n \"$BV\" ]"
check "workflow.md ma tę samą wersję"             "[ \"$BV\" = \"$WV\" ] && [ -n \"$WV\" ]"

echo ""
echo "▸ Referencje plików w builder.md"
# Pliki/skrypty wywoływane przez Buildera w docelowym projekcie — install.sh musi je dostarczać
for ref in "scripts/notify.sh" "agents_catalog.md" ".workflow/config"; do
    if grep -qF "$ref" builder.md; then
        if [ -f "$ref" ]; then
            ok "builder.md odnosi się do $ref → istnieje w repo"
        else
            fail "builder.md odnosi się do $ref → BRAK W REPO (install.sh nie dostarczy)"
        fi
    fi
done

echo ""
echo "▸ Referencje plików w sokol.md"
for ref in "agents_catalog.md"; do
    if grep -qF "$ref" sokol.md; then
        if [ -f "$ref" ]; then
            ok "sokol.md odnosi się do $ref → istnieje w repo"
        else
            fail "sokol.md odnosi się do $ref → BRAK W REPO"
        fi
    fi
done

echo ""
echo "▸ install.sh kopiuje wszystkie pliki referencjowane"
check "install.sh kopiuje agents_catalog.md"   "grep -qF 'agents_catalog.md' install.sh"
check "install.sh kopiuje scripts/notify.sh"   "grep -qF 'scripts/notify.sh' install.sh"
check "install.sh tworzy .workflow/config"     "grep -qF '.workflow/config' install.sh"
check "install.sh kopiuje templates/plan_single.md"  "grep -qF 'plan_single.md' install.sh"
check "install.sh kopiuje templates/plan_batch.md"   "grep -qF 'plan_batch.md' install.sh"
check "install.sh tworzy MD/archive"           "grep -qE 'mkdir -p MD/archive' install.sh"
check "install.sh tworzy MD/TODO.md"           "grep -qF 'MD/TODO.md' install.sh"
check "install.sh usuwa stare osadzone workflow" "grep -qF 'strip_legacy_embedded_workflow' install.sh"

echo ""
echo "▸ Spójność reguł (kanoniczne źródła)"
check "builder.md ma kanoniczną checklistę finalizacji" \
    "grep -qF 'Checklista finalizacji (BLOKUJĄCA)' builder.md"
check "workflow.md linkuje do builder.md jako kanonicznej" \
    "grep -qF 'builder.md' workflow.md"
OLD_AGENT_NAME_PATTERN='KLAUD[I]USZ|Klaud[i]u|Cla[u]diu'
check "kanoniczne źródła nie zawierają starej nazwy agenta" \
    "! grep -RqiE \"$OLD_AGENT_NAME_PATTERN\" builder.md sokol.md workflow.md README.md templates"

echo ""
echo "▸ README — pliki wymienione w tabeli istnieją"
for f in "builder.md" "sokol.md" "workflow.md" "cel.md" "install.sh" ".workflow/config" "templates/plan_single.md" "templates/plan_batch.md" "update-all.sh" "CHANGELOG.md"; do
    if grep -qF "$f" README.md; then
        if [ -e "$f" ]; then
            ok "README → $f → istnieje"
        else
            fail "README → $f → BRAK"
        fi
    fi
done

echo ""
echo "═══════════════════════════════════════════════"
TOTAL=$((PASS + FAIL))
if [ $FAIL -eq 0 ]; then
    echo "  ✅ Wszystko OK ($PASS/$TOTAL)"
    exit 0
else
    echo "  ❌ Problemy: $FAIL/$TOTAL"
    exit 1
fi
