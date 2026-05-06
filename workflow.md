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

## Faza 0: Skanowanie (oszczędność tokenów)

Zamiast naprawiać issues jeden po jednym (kosztowne — pełny cykl kontekstu per issue):

1. Sokół skanuje cały projekt/moduł **raz**
2. Zapisuje WSZYSTKIE znalezione issues do `issues_found.md`
3. Grupuje: **batche** (powiązane/proste, max 5 per batch) vs **individual** (złożone)
4. Orkiestrator zatwierdza podział
5. Praca idzie batch po batchu (jeden plan per batch) → potem individual issues

**Kiedy batchować:** ten sam plik/moduł, ten sam wzorzec fixu, LOW/MEDIUM severity, brak zależności.
**Kiedy osobno:** architektura, CRITICAL, auth/płatności, nieoczywiste rozwiązanie.

## Proces ping-pong

### 1. Sokół rozpoczyna
Sokół pisze prompt dla Klaudiusza (dla pojedynczego issue LUB całego batcha) zawierający:
- Opis znalezionego problemu/pomysłu (lub lista issues z batcha)
- Propozycję rozwiązania
- Pytanie czy Klaudiusz się zgadza (jeśli nie — chce argument)
- Pytanie o ryzyka w implementacji

### 2. Klaudiusz odpowiada
Klaudiusz NIE implementuje — zamiast tego:
- Tworzy/aktualizuje plik `plan_nazwa_wdrożenia.md` (status: DRAFT lub W DYSKUSJI)
- Mówi czy się zgadza z Sokołem (jeśli nie — dlaczego)
- Proponuje alternatywy jeśli widzi lepsze rozwiązanie
- Identyfikuje ryzyka
- **OBOWIĄZKOWO pisze prompt zwrotny dla Sokoła** (wypisany w terminalu)

### 3. Iteracja
Orkiestrator kopiuje prompt do Sokoła. Proces się powtarza aż oba agenty są zadowolone z planu.

### 4. Zatwierdzenie

Gdy oba agenty potwierdzą plan, Sokół ocenia złożoność:

**Prosty fix** (defensywny, pełny konsensus, brak ryzyk architektonicznych):
→ Sokół pisze: "Plan jest gotowy do implementacji."
→ Klaudiusz zmienia status na ZATWIERDZONY i wdraża.

**Złożona zmiana** (architektura, nowe serwisy, spór, ryzyko średnie+):
→ Sokół pisze: "Plan jest gotowy do oceny przez senior-architect."
→ Klaudiusz wywołuje senior-architecta → jeśli OK: wdraża. Jeśli nie: powrót do ping-pongu.

### 5. Po wdrożeniu
- Testy muszą przejść (zielone)
- Code-review (jeśli wymagany: 3+ pliki, logika biznesowa, nowy pattern)
- `git commit` + `git push` na GitHub (automatycznie po zielonych testach)
- `docker compose up -d --build` (automatycznie po pushu — rebuild i deploy)
- Aktualizacja CLAUDE.md (jeśli potrzeba)
- Aktualizacja README (jeśli potrzeba)
- Oznaczenie tasku jako DONE w todo.md

### 5a. Prompt zwrotny do Sokoła (obowiązkowy)
Po zakończeniu wdrożenia Klaudiusz **MUSI** wypisać w terminalu prompt po polsku dla Sokoła:
- Co zostało zrobione (podsumowanie zmian)
- Jakie testy przeszły (liczba, wynik)
- Czy deploy się powiódł (docker rebuild + push)
- **Pytanie:** jaki jest kolejny etap planu / co robimy dalej?

Orkiestrator kopiuje ten prompt do Sokoła → Sokół wskazuje kolejne zadanie → cykl się powtarza.

### 6. Gdy coś pójdzie nie tak

**Testy padają po wdrożeniu:**
- Klaudiusz naprawia i puszcza testy ponownie
- Jeśli fix jest nietrywalny (zmiana podejścia) → nowa runda ping-pong z Sokołem

**Code-review znajduje HIGH issues:**
- Klaudiusz naprawia → ponowne testy → push

**Senior-architect odrzuca plan:**
- Powrót do ping-pongu z uwagami architecta jako nowym inputem

## Statusy planu

```
DRAFT → W DYSKUSJI → GOTOWY DO OCENY → ZATWIERDZONY → WDROŻONY
```

- DRAFT: Klaudiusz tworzy plan na podstawie pierwszego promptu Sokoła
- W DYSKUSJI: ping-pong trwa
- GOTOWY DO OCENY: oba agenty potwierdziły, czeka na senior-architect (lub pomijamy)
- ZATWIERDZONY: gotowy do implementacji (po zielonym świetle Orkiestratora)
- WDROŻONY: kod wdrożony, testy zielone, pushnięty

## Wyjaśnienie dla Orkiestratora

Pod każdą odpowiedzią agenta — sekcja prostym językiem:
- Co to za zmiana/błąd/ulepszenie
- Jak działa teraz
- Jaka jest propozycja
- Co to zmieni
- Jakie są ryzyka
