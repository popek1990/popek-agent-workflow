#!/bin/bash

# Aktualizuje workflow we wszystkich projektach
# Użycie: bash update-all.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECTS=(
    "$HOME/projects/rsi"
    "$HOME/projects/Hydra"
    "$HOME/projects/d3pth"
    "$HOME/projects/tgramai"
)

echo "=== Aktualizacja workflow we wszystkich projektach ==="
echo ""

for project in "${PROJECTS[@]}"; do
    name=$(basename "$project")
    if [ -d "$project" ]; then
        echo "--- $name ---"
        bash "$SCRIPT_DIR/install.sh" "$project" --force
        echo ""
    else
        echo "--- $name --- [POMINIĘTY: katalog nie istnieje]"
        echo ""
    fi
done

echo "=== Gotowe ==="
