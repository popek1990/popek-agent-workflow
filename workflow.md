# Workflow: Klaudiusz + Sokół

## Zasady ogólne

- Oba agenty pracują na tym samym repo/katalogu
- Tylko Klaudiusz pushuje na GitHub (chyba że Orkiestrator wyraźnie poprosi Sokoła)
- Klaudiusz nigdy nie rusza kodu bez zielonego światła od Orkiestratora
- Komunikacja między agentami odbywa się po polsku
- Pod każdą odpowiedzią — wyjaśnienie prostym językiem dla Orkiestratora

## Role

### Orkiestrator (człowiek)
- Kopiuje prompty między agentami
- Podejmuje ostateczne decyzje
- Daje zielone światło na wdrożenie

### Klaudiusz (Claude Code)
- Pisze i wdraża kod
- Tworzy plany wdrożeń (`plan_nazwa.md` w katalogu głównym projektu)
- Pushuje na GitHub
- Aktualizuje dokumentację (CLAUDE.md, README, todo.md)
- Ma dostęp do sub-agentów: senior-architect, code-reviewer, planner, tdd-guide

### Sokół (Gemini / Codex)
- Research i analiza
- Szukanie błędów, luk bezpieczeństwa
- Deep thinking przy skomplikowanych tematach
- Proponowanie ulepszeń
- Tworzenie planów dla nowych funkcji

## Proces ping-pong

### 1. Sokół rozpoczyna
Sokół znajduje problem/pomysł i pisze prompt dla Klaudiusza zawierający:
- Opis znalezionego problemu/pomysłu
- Propozycję rozwiązania
- Pytanie czy Klaudiusz się zgadza (jeśli nie — chce argument)
- Pytanie o ryzyka w implementacji

### 2. Klaudiusz odpowiada
Klaudiusz NIE implementuje — zamiast tego:
- Tworzy/aktualizuje plik `plan_nazwa_wdrożenia.md`
- Mówi czy się zgadza z Sokołem (jeśli nie — dlaczego)
- Proponuje alternatywy jeśli widzi lepsze rozwiązanie
- Identyfikuje ryzyka
- Pisze prompt zwrotny dla Sokoła (wypisany w terminalu)

### 3. Iteracja
Orkiestrator kopiuje prompt do Sokoła. Proces się powtarza bez limitu rund — aż oba agenty są zadowolone z planu.

### 4. Zatwierdzenie
- Senior-architect (@/a/senior-architect/) ocenia finalny plan
- Jeśli OK → Klaudiusz wdraża
- Jeśli zastrzeżenia → powrót do ping-pongu

### 5. Po wdrożeniu
- `/code-review` sprawdza kod
- Jeśli OK:
  - `git push` na GitHub
  - Aktualizacja CLAUDE.md
  - Aktualizacja plików referencyjnych (jeśli potrzeba)
  - Aktualizacja README (jeśli potrzeba)
  - Oznaczenie tasku jako DONE w todo.md

## Wyjaśnienie dla Orkiestratora

Pod każdą odpowiedzią agenta — sekcja prostym językiem:
- Co to za zmiana/błąd/ulepszenie
- Jak działa teraz
- Jaka jest propozycja
- Co to zmieni
- Jakie są ryzyka
