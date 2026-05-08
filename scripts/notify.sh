#!/bin/bash
# Powiadomienie orkiestratora o zakończeniu wdrożenia
# Użycie: bash scripts/notify.sh "Treść wiadomości"
# Działa na: WSL2/Windows (popup), Linux (notify-send), macOS (osascript)

MSG="${1:-Wdrożenie zakończone — prompt zwrotny gotowy do skopiowania do Sokoła}"
TITLE="${2:-Builder: Zadanie skończone}"

if command -v powershell.exe &>/dev/null; then
    powershell.exe -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; [System.Windows.Forms.MessageBox]::Show('$MSG','$TITLE')" 2>/dev/null
elif command -v notify-send &>/dev/null; then
    notify-send "$TITLE" "$MSG"
elif command -v osascript &>/dev/null; then
    osascript -e "display notification \"$MSG\" with title \"$TITLE\""
fi

echo -e "\a"
